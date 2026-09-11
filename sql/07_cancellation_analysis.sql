-- ============================================================
-- 07_cancellation_analysis.sql
-- Retail Sales & Customer Performance Analytics
-- Purpose: Analyze cancellation volume, value, and impact
-- ============================================================

-- ============================================================
-- 1. OVERALL SALES AND CANCELLATION SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT CASE
        WHEN transaction_type = 'Sale'
        THEN invoice
    END) AS sale_orders,

    COUNT(DISTINCT CASE
        WHEN transaction_type = 'Cancellation'
        THEN invoice
    END) AS cancellation_orders,

    ROUND(
        SUM(
            CASE
                WHEN transaction_type = 'Sale'
                THEN quantity * price
                ELSE 0
            END
        ),
        2
    ) AS gross_sales_value,

    ROUND(
        ABS(
            SUM(
                CASE
                    WHEN transaction_type = 'Cancellation'
                    THEN quantity * price
                    ELSE 0
                END
            )
        ),
        2
    ) AS cancellation_value

FROM retail_analysis
WHERE transaction_type IN ('Sale', 'Cancellation');


-- Expected validated results:
-- Sale invoices       = 40,077
-- Cancellation invoices = 8,291
-- Gross Sale value    = 20,476,260.43
-- Cancellation value  = 1,462,424.18
-- Net sales value     = 19,013,836.25



-- ============================================================
-- 2. TOP MERCHANDISE CANCELLATIONS BY VALUE
-- ============================================================

SELECT
    stock_code,

    ROUND(
        ABS(SUM(quantity * price)),
        2
    ) AS cancellation_value,

    ABS(SUM(quantity)) AS cancelled_quantity,

    COUNT(DISTINCT invoice) AS cancellation_invoices

FROM retail_analysis
WHERE transaction_type = 'Cancellation'
  AND stock_code NOT IN (
      'M', 'DOT', 'POST',
      'AMAZONFEE', 'BANK CHARGES',
      'D', 'CRUK'
  )
GROUP BY stock_code
ORDER BY cancellation_value DESC
LIMIT 10;


-- Important validated case:
-- StockCode 23843 had a full reversal of 80,995 units.



-- ============================================================
-- 3. NON-MERCHANDISE / FINANCIAL CODES REVIEW
-- ============================================================

SELECT
    stock_code,
    description,
    COUNT(*) AS row_count,
    SUM(quantity) AS quantity,
    ROUND(SUM(quantity * price), 2) AS value,
    MIN(price) AS min_price,
    MAX(price) AS max_price

FROM retail_analysis

WHERE stock_code IN (
    'AMAZONFEE',
    'BANK CHARGES',
    'D',
    'CRUK'
)

GROUP BY
    stock_code,
    description

ORDER BY
    stock_code,
    ABS(SUM(quantity * price)) DESC;


-- These codes were separated from merchandise rankings:
-- AMAZONFEE   = Amazon Fee
-- BANK CHARGES = Bank Charges
-- D           = Discount
-- CRUK        = CRUK Commission



-- ============================================================
-- 4. MONTHLY CANCELLATION BEHAVIOR
-- ============================================================

SELECT
    DATE_TRUNC('month', invoice_date) AS month,

    ROUND(
        ABS(SUM(quantity * price)),
        2
    ) AS cancellation_value,

    COUNT(DISTINCT invoice) AS cancellation_invoices,

    ABS(SUM(quantity)) AS cancelled_quantity

FROM retail_analysis

WHERE transaction_type = 'Cancellation'

GROUP BY month
ORDER BY month;



-- ============================================================
-- 5. MONTHLY CANCELLATION IMPACT %
-- ============================================================

SELECT
    DATE_TRUNC('month', invoice_date) AS month,

    ROUND(
        ABS(
            SUM(
                CASE
                    WHEN transaction_type = 'Cancellation'
                    THEN quantity * price
                    ELSE 0
                END
            )
        )
        /
        NULLIF(
            SUM(
                CASE
                    WHEN transaction_type = 'Sale'
                    THEN quantity * price
                    ELSE 0
                END
            ),
            0
        ) * 100,
        2
    ) AS cancellation_impact_pct

FROM retail_analysis

WHERE transaction_type IN ('Sale', 'Cancellation')

GROUP BY DATE_TRUNC('month', invoice_date)

ORDER BY month;


-- Key validated findings:
-- Overall cancellation value ≈ 7.14% of gross Sale value.
-- January 2011 had the highest cancellation impact
-- among complete months at approximately 19.04%.
-- December 2011 is a partial month and should be
-- interpreted cautiously.
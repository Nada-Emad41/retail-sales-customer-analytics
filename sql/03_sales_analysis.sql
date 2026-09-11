-- ============================================================
-- 03_sales_analysis.sql
-- Retail Sales & Customer Performance Analytics
-- Purpose: Analyze overall and monthly sales performance
-- ============================================================

-- ============================================================
-- 1. OVERALL GROSS SALES VALUE
-- ============================================================

SELECT
    ROUND(SUM(quantity * price), 2) AS gross_sales_value
FROM retail_analysis
WHERE transaction_type = 'Sale';

-- Expected validated result:
-- 20,476,260.43



-- ============================================================
-- 2. YEARLY GROSS SALES
-- ============================================================

SELECT
    EXTRACT(YEAR FROM invoice_date) AS year,
    ROUND(SUM(quantity * price), 2) AS gross_sales_value
FROM retail_analysis
WHERE transaction_type = 'Sale'
GROUP BY year
ORDER BY year;

-- Important:
-- 2009 and 2011 are partial years in this dataset.



-- ============================================================
-- 3. MONTHLY GROSS SALES
-- ============================================================

SELECT
    DATE_TRUNC('month', invoice_date) AS month,
    ROUND(SUM(quantity * price), 2) AS gross_sales_value
FROM retail_analysis
WHERE transaction_type = 'Sale'
GROUP BY month
ORDER BY month;



-- ============================================================
-- 4. MONTH-OVER-MONTH GROSS SALES GROWTH
-- ============================================================

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(quantity * price) AS gross_sales_value
    FROM retail_analysis
    WHERE transaction_type = 'Sale'
    GROUP BY month
),

monthly_comparison AS (
    SELECT
        month,
        gross_sales_value,
        LAG(gross_sales_value) OVER (
            ORDER BY month
        ) AS previous_month_sales
    FROM monthly_sales
)

SELECT
    month,
    ROUND(gross_sales_value, 2) AS gross_sales_value,
    ROUND(previous_month_sales, 2) AS previous_month_sales,

    ROUND(
        (
            gross_sales_value - previous_month_sales
        )
        / NULLIF(previous_month_sales, 0) * 100,
        2
    ) AS mom_growth_pct

FROM monthly_comparison
ORDER BY month;



-- ============================================================
-- 5. MONTHLY SALES OPERATING METRICS
-- ============================================================

SELECT
    DATE_TRUNC('month', invoice_date) AS month,

    ROUND(
        SUM(quantity * price),
        2
    ) AS gross_sales_value,

    SUM(quantity) AS total_quantity_sold,

    COUNT(DISTINCT invoice) AS total_orders,

    ROUND(
        SUM(quantity * price)
        / NULLIF(COUNT(DISTINCT invoice), 0),
        2
    ) AS average_order_value,

    ROUND(
        SUM(quantity * price)
        / NULLIF(SUM(quantity), 0),
        2
    ) AS average_selling_price_per_unit,

    ROUND(
        SUM(quantity)::numeric
        / NULLIF(COUNT(DISTINCT invoice), 0),
        2
    ) AS average_units_per_order

FROM retail_analysis
WHERE transaction_type = 'Sale'
GROUP BY month
ORDER BY month;



-- ============================================================
-- 6. MONTHLY GROSS SALES, CANCELLATIONS, AND NET SALES
-- ============================================================

SELECT
    DATE_TRUNC('month', invoice_date) AS month,

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
    ) AS cancellation_value,

    ROUND(
        SUM(
            CASE
                WHEN transaction_type IN ('Sale', 'Cancellation')
                THEN quantity * price
                ELSE 0
            END
        ),
        2
    ) AS net_sales_value

FROM retail_analysis
WHERE transaction_type IN ('Sale', 'Cancellation')
GROUP BY month
ORDER BY month;



-- ============================================================
-- 7. MONTHLY CANCELLATION IMPACT %
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
GROUP BY month
ORDER BY month;


-- Key validated findings:
-- Gross Sale value        = 20,476,260.43
-- Cancellation value      = 1,462,424.18
-- Net sales value         = 19,013,836.25
-- Overall cancellation impact ≈ 7.14%
--
-- January 2011 had the highest cancellation impact
-- among complete months at approximately 19.04%.
--
-- December 2009 and December 2011 are partial boundary months
-- and should be interpreted cautiously.
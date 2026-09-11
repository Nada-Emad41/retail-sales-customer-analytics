-- ============================================================
-- 06_customer_analysis.sql
-- Retail Sales & Customer Performance Analytics
-- Purpose: Analyze identified customer behavior and concentration
-- ============================================================

-- ============================================================
-- 1. TOP 10 IDENTIFIED CUSTOMERS BY NET SALES
-- ============================================================

SELECT
    customer_id,
    ROUND(SUM(quantity * price), 2) AS net_sales_value,
    COUNT(DISTINCT invoice) AS order_count,
    SUM(quantity) AS net_quantity
FROM retail_analysis
WHERE transaction_type IN ('Sale', 'Cancellation')
  AND customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY net_sales_value DESC
LIMIT 10;



-- ============================================================
-- 2. TOP 10 CUSTOMER SALES CONCENTRATION
-- ============================================================

WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(quantity * price) AS net_sales_value
    FROM retail_analysis
    WHERE transaction_type IN ('Sale', 'Cancellation')
      AND customer_id IS NOT NULL
    GROUP BY customer_id
),

ranked_customers AS (
    SELECT
        customer_id,
        net_sales_value,
        ROW_NUMBER() OVER (
            ORDER BY net_sales_value DESC
        ) AS customer_rank
    FROM customer_sales
)

SELECT
    ROUND(SUM(net_sales_value), 2) AS total_identified_customer_sales,

    ROUND(
        SUM(
            CASE
                WHEN customer_rank <= 10
                THEN net_sales_value
                ELSE 0
            END
        ),
        2
    ) AS top_10_customer_sales,

    ROUND(
        SUM(
            CASE
                WHEN customer_rank <= 10
                THEN net_sales_value
                ELSE 0
            END
        )
        / NULLIF(SUM(net_sales_value), 0) * 100,
        2
    ) AS top_10_sales_share_pct

FROM ranked_customers;


-- Expected validated results:
-- Total identified customer net sales = 16,289,991.27
-- Top 10 customer sales share         = 16.30%



-- ============================================================
-- 3. REPEAT PURCHASE BEHAVIOR
-- ============================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice) AS order_count
    FROM retail_analysis
    WHERE transaction_type = 'Sale'
      AND customer_id IS NOT NULL
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,

    COUNT(
        CASE
            WHEN order_count = 1
            THEN 1
        END
    ) AS one_time_customers,

    COUNT(
        CASE
            WHEN order_count > 1
            THEN 1
        END
    ) AS repeat_customers,

    ROUND(
        COUNT(
            CASE
                WHEN order_count > 1
                THEN 1
            END
        )::numeric
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS repeat_customer_pct

FROM customer_orders;


-- Expected validated results:
-- Total identified purchasing customers = 5,878
-- One-time customers                     = 1,623
-- Repeat customers                       = 4,255
-- Repeat customer rate                   = 72.39%



-- ============================================================
-- 4. VALIDATE IDENTIFIED CUSTOMER NET SALES
-- ============================================================

SELECT
    ROUND(
        SUM(quantity * price),
        2
    ) AS identified_net_sales
FROM retail_analysis
WHERE transaction_type IN ('Sale', 'Cancellation')
  AND customer_id IS NOT NULL;


-- Expected validated result:
-- 16,289,991.27



-- ============================================================
-- 5. MISSING CUSTOMER ID IMPACT
-- ============================================================

SELECT
    COUNT(*) AS total_sale_rows,

    COUNT(*) FILTER (
        WHERE customer_id IS NULL
    ) AS missing_customer_rows,

    COUNT(*) FILTER (
        WHERE customer_id IS NOT NULL
    ) AS identified_customer_rows,

    ROUND(
        COUNT(*) FILTER (
            WHERE customer_id IS NULL
        )::numeric
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_customer_row_pct,

    ROUND(
        SUM(
            CASE
                WHEN customer_id IS NULL
                THEN quantity * price
                ELSE 0
            END
        ),
        2
    ) AS unidentified_customer_sales,

    ROUND(
        SUM(
            CASE
                WHEN customer_id IS NOT NULL
                THEN quantity * price
                ELSE 0
            END
        ),
        2
    ) AS identified_customer_sales

FROM retail_analysis
WHERE transaction_type = 'Sale';


-- Expected validated results:
-- Total Sale rows              = 1,007,895
-- Missing Customer ID rows     = 228,488
-- Missing Customer ID share    = 22.67%
-- Unidentified gross Sale value = 3,101,456.18
--
-- Customer-level analysis excludes NULL Customer IDs because
-- unique customers and repeat behavior cannot be identified
-- reliably without a customer identifier.
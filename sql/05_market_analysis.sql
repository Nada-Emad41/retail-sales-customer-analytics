-- ============================================================
-- 05_market_analysis.sql
-- Retail Sales & Customer Performance Analytics
-- Purpose: Analyze market performance and geographic concentration
-- ============================================================

-- ============================================================
-- 1. MARKET PERFORMANCE BY COUNTRY
-- ============================================================

SELECT
    country,
    ROUND(SUM(quantity * price), 2) AS net_sales_value,
    COUNT(DISTINCT invoice) AS order_count,
    COUNT(DISTINCT customer_id) AS customer_count,

    ROUND(
        SUM(quantity * price)
        / NULLIF(COUNT(DISTINCT invoice), 0),
        2
    ) AS average_order_value,

    ROUND(
        SUM(quantity * price)
        / NULLIF(COUNT(DISTINCT customer_id), 0),
        2
    ) AS revenue_per_customer

FROM retail_analysis
WHERE transaction_type IN ('Sale', 'Cancellation')
GROUP BY country
ORDER BY net_sales_value DESC;



-- ============================================================
-- 2. UK MARKET CONCENTRATION
-- ============================================================

WITH market_sales AS (
    SELECT
        country,
        SUM(quantity * price) AS net_sales_value
    FROM retail_analysis
    WHERE transaction_type IN ('Sale', 'Cancellation')
    GROUP BY country
)

SELECT
    ROUND(SUM(net_sales_value), 2) AS total_net_sales,

    ROUND(
        SUM(
            CASE
                WHEN country = 'United Kingdom'
                THEN net_sales_value
                ELSE 0
            END
        ),
        2
    ) AS uk_net_sales,

    ROUND(
        SUM(
            CASE
                WHEN country = 'United Kingdom'
                THEN net_sales_value
                ELSE 0
            END
        )
        / NULLIF(SUM(net_sales_value), 0) * 100,
        2
    ) AS uk_sales_share_pct

FROM market_sales;


-- Expected validated results:
-- Total net sales = 19,013,836.25
-- UK net sales    = 16,144,362.89
-- UK share        = 84.91%
--
-- Interpretation:
-- Net sales are highly concentrated in the United Kingdom.
-- Some smaller international markets show higher AOV,
-- but customer-based market metrics should be interpreted
-- cautiously when customer counts are very small.
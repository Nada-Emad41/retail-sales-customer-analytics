-- ============================================================
-- 04_product_analysis.sql
-- Retail Sales & Customer Performance Analytics
-- Purpose: Analyze product performance using net sales
-- ============================================================

-- ============================================================
-- 1. PRODUCT DESCRIPTION CONSISTENCY CHECK
-- ============================================================

SELECT
    COUNT(*) AS stock_codes_with_multiple_descriptions
FROM (
    SELECT
        stock_code
    FROM retail_analysis
    WHERE transaction_type IN ('Sale', 'Cancellation')
      AND stock_code NOT IN ('M', 'DOT', 'POST')
    GROUP BY stock_code
    HAVING COUNT(DISTINCT description) > 1
) AS inconsistent_products;

-- Expected validated result:
-- 648 StockCodes have multiple descriptions.
-- Therefore, StockCode is used as the main product identifier.



-- ============================================================
-- 2. TOP 10 PRODUCTS BY NET SALES VALUE
-- ============================================================

SELECT
    stock_code,
    ROUND(SUM(quantity * price), 2) AS net_sales_value,
    SUM(quantity) AS net_quantity,
    COUNT(DISTINCT invoice) AS order_count
FROM retail_analysis
WHERE transaction_type IN ('Sale', 'Cancellation')
  AND stock_code NOT IN (
      'M', 'DOT', 'POST',
      'AMAZONFEE', 'BANK CHARGES',
      'D', 'CRUK'
  )
GROUP BY stock_code
ORDER BY net_sales_value DESC
LIMIT 10;



-- ============================================================
-- 3. TOP 10 PRODUCTS BY NET QUANTITY
-- ============================================================

SELECT
    stock_code,
    ROUND(SUM(quantity * price), 2) AS net_sales_value,
    SUM(quantity) AS net_quantity,
    COUNT(DISTINCT invoice) AS order_count
FROM retail_analysis
WHERE transaction_type IN ('Sale', 'Cancellation')
  AND stock_code NOT IN (
      'M', 'DOT', 'POST',
      'AMAZONFEE', 'BANK CHARGES',
      'D', 'CRUK'
  )
GROUP BY stock_code
ORDER BY net_quantity DESC
LIMIT 10;



-- ============================================================
-- 4. PRODUCT CONCENTRATION
-- ============================================================

WITH product_sales AS (
    SELECT
        stock_code,
        SUM(quantity * price) AS net_sales_value
    FROM retail_analysis
    WHERE transaction_type IN ('Sale', 'Cancellation')
      AND stock_code NOT IN (
          'M', 'DOT', 'POST',
          'AMAZONFEE', 'BANK CHARGES',
          'D', 'CRUK'
      )
    GROUP BY stock_code
),

ranked_products AS (
    SELECT
        stock_code,
        net_sales_value,
        ROW_NUMBER() OVER (
            ORDER BY net_sales_value DESC
        ) AS product_rank
    FROM product_sales
)

SELECT
    ROUND(SUM(net_sales_value), 2) AS total_merchandise_net_sales,

    ROUND(
        SUM(
            CASE
                WHEN product_rank <= 10
                THEN net_sales_value
                ELSE 0
            END
        ),
        2
    ) AS top_10_product_sales,

    ROUND(
        SUM(
            CASE
                WHEN product_rank <= 10
                THEN net_sales_value
                ELSE 0
            END
        )
        / NULLIF(SUM(net_sales_value), 0) * 100,
        2
    ) AS top_10_product_share_pct

FROM ranked_products;


-- Expected validated results:
-- Total merchandise net sales = 18,955,077.45
-- Top 10 product sales        = 1,437,948.23
-- Top 10 product share        = 7.59%



-- ============================================================
-- 5. VALIDATION CASE: LARGE SALE FULLY CANCELLED
-- ============================================================

SELECT
    invoice,
    stock_code,
    description,
    quantity,
    price,
    quantity * price AS transaction_value,
    customer_id,
    country,
    invoice_date,
    transaction_type
FROM retail_analysis
WHERE stock_code = '23843'
ORDER BY invoice_date;


-- Validated finding:
-- StockCode 23843 had an 80,995-unit sale that was fully
-- cancelled 12 minutes later.
-- This demonstrates why net sales should be used for
-- product-performance rankings rather than gross sales alone.
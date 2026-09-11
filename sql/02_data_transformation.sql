-- ============================================================
-- 02_data_transformation.sql
-- Retail Sales & Customer Performance Analytics
-- Purpose: Build clean and analysis-ready tables
-- ============================================================

-- ============================================================
-- 1. CREATE DEDUPLICATED CLEAN TABLE
-- ============================================================

DROP TABLE IF EXISTS retail_clean;

CREATE TABLE retail_clean AS

SELECT
    invoice,
    stock_code,
    description,
    quantity,
    invoice_date,
    price,
    customer_id,
    country

FROM (
    SELECT
        combined.*,

        ROW_NUMBER() OVER (
            PARTITION BY
                invoice,
                stock_code,
                description,
                quantity,
                invoice_date,
                price,
                customer_id,
                country
            ORDER BY invoice
        ) AS row_num

    FROM (
        SELECT
            invoice,
            stock_code,
            description,
            quantity,
            invoice_date,
            price,
            customer_id,
            country
        FROM raw_retail_2009_2010

        UNION ALL

        SELECT
            invoice,
            stock_code,
            description,
            quantity,
            invoice_date,
            price,
            customer_id,
            country
        FROM raw_retail_2010_2011

    ) AS combined

) AS numbered

WHERE row_num = 1;


-- Expected validated result:
-- retail_clean = 1,033,036 rows



-- ============================================================
-- 2. VALIDATE CLEAN TABLE ROW COUNT
-- ============================================================

SELECT
    COUNT(*) AS retail_clean_rows
FROM retail_clean;



-- ============================================================
-- 3. CREATE ANALYSIS TABLE WITH TRANSACTION CLASSIFICATION
-- ============================================================

DROP TABLE IF EXISTS retail_analysis;

CREATE TABLE retail_analysis AS

SELECT
    invoice,
    stock_code,
    description,
    quantity,
    invoice_date,
    price,
    customer_id,
    country,

    CASE
        WHEN invoice LIKE 'C%'
             AND quantity < 0
            THEN 'Cancellation'

        WHEN invoice LIKE 'C%'
             AND quantity > 0
            THEN 'C-prefixed exception'

        WHEN invoice NOT LIKE 'C%'
             AND quantity < 0
             AND price = 0
            THEN 'Non-standard adjustment'

        WHEN stock_code = 'B'
             AND description = 'Adjust bad debt'
             AND price < 0
            THEN 'Financial adjustment'

        WHEN invoice NOT LIKE 'C%'
             AND quantity > 0
             AND price = 0
            THEN 'Zero-price transaction'

        WHEN invoice NOT LIKE 'C%'
             AND quantity > 0
             AND price > 0
            THEN 'Sale'

        ELSE 'Unclassified'

    END AS transaction_type

FROM retail_clean;



-- ============================================================
-- 4. VALIDATE ANALYSIS TABLE
-- ============================================================

SELECT
    COUNT(*) AS retail_analysis_rows
FROM retail_analysis;


SELECT
    transaction_type,
    COUNT(*) AS row_count
FROM retail_analysis
GROUP BY transaction_type
ORDER BY row_count DESC;


-- Expected validated classification counts:
-- Sale                     = 1,007,895
-- Cancellation             = 19,103
-- Non-standard adjustment  = 3,393
-- Zero-price transaction   = 2,639
-- Financial adjustment     = 5
-- C-prefixed exception     = 1
-- Unclassified             = 0
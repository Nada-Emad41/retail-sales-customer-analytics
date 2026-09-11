-- ============================================================
-- 01_data_quality_checks.sql
-- Retail Sales & Customer Performance Analytics
-- Purpose: Validate source data quality before transformation
-- ============================================================

-- ============================================================
-- 1. RAW TABLE ROW COUNTS
-- ============================================================

SELECT
    '2009-2010' AS source_period,
    COUNT(*) AS row_count
FROM raw_retail_2009_2010

UNION ALL

SELECT
    '2010-2011' AS source_period,
    COUNT(*) AS row_count
FROM raw_retail_2010_2011;


-- Expected validated counts:
-- 2009-2010 = 525,461
-- 2010-2011 = 541,910



-- ============================================================
-- 2. COMBINED RAW ROW COUNT
-- ============================================================

SELECT
    COUNT(*) AS combined_raw_rows
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
) AS combined;


-- Expected result:
-- 1,067,371 rows



-- ============================================================
-- 3. DATE RANGE BY SOURCE TABLE
-- ============================================================

SELECT
    '2009-2010' AS source_period,
    MIN(invoice_date) AS first_date,
    MAX(invoice_date) AS last_date
FROM raw_retail_2009_2010

UNION ALL

SELECT
    '2010-2011' AS source_period,
    MIN(invoice_date) AS first_date,
    MAX(invoice_date) AS last_date
FROM raw_retail_2010_2011;


-- Validated observation:
-- The two source sheets overlap in December 2010.



-- ============================================================
-- 4. EXACT CROSS-SHEET OVERLAP
-- ============================================================

SELECT
    COUNT(*) AS overlapping_rows
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

    INTERSECT ALL

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
) AS overlapping_rows;


-- Expected validated result:
-- 22,523 rows occur in both source tables.



-- ============================================================
-- 5. EXCESS EXACT DUPLICATE ROWS ACROSS COMBINED DATA
-- ============================================================

SELECT
    COUNT(*) AS excess_exact_duplicate_rows
FROM (
    SELECT
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
WHERE row_num > 1;


-- Expected validated result:
-- 34,335 excess exact duplicate rows



-- ============================================================
-- 6. DEDUPLICATED ROW COUNT
-- ============================================================

SELECT
    COUNT(*) AS deduplicated_rows
FROM (
    SELECT
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
-- 1,033,036 rows



-- ============================================================
-- 7. STOCK CODES WITH MULTIPLE DESCRIPTIONS
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
-- 648 StockCodes have more than one description.
-- Product analysis therefore uses StockCode as the main identifier.



-- ============================================================
-- 8. MISSING CUSTOMER ID IMPACT ON SALE ROWS
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


-- Validated results:
-- Total Sale rows                = 1,007,895
-- Missing Customer ID rows       = 228,488
-- Missing Customer ID row share  = 22.67%
-- Gross sales without Customer ID = 3,101,456.18
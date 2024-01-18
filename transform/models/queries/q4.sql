{{
    config(
        materialized='view'
    )
}}

WITH order_years AS (
    -- CTE extracting the year from order dates
    SELECT
        vendor_id, -- assuming vendor_id is unique across countries
        EXTRACT(YEAR FROM date_local) AS year,
        ROUND(SUM(gmv_local), 2) AS total_gmv
    FROM {{ source('csv_source', 'orders') }}
    INNER JOIN vendors ON vendors.id = orders.vendor_id
    GROUP BY vendor_id, year
),

-- vendor_year_gmv AS (
--     -- CTE calculating GMV for each vendor by year
--     SELECT
--         o.vendor_id,
--         o.year,
--         ROUND(SUM(o.gmv_local), 2) AS total_gmv
--     FROM order_years o
--     GROUP BY o.vendor_id, o.year
-- ),

vendor_details AS (
    -- CTE retrieving vendor details
    SELECT
        id AS vendor_id,
        vendor_name,
        country_name
    FROM {{ source('csv_source', 'vendors') }}
),

vendors_gmv_per_year AS (
    -- CTE combining vendor details with their GMV by year
    SELECT
        vd.country_name,
        vd.vendor_name,
        v.year,
        v.total_gmv
    FROM vendor_year_gmv v
    INNER JOIN vendor_details vd ON v.vendor_id = vd.vendor_id
),

ranked_vendors_per_year AS (
    -- CTE ranking vendors within each country and year by total GMV
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY country_name, year ORDER BY total_gmv DESC) AS rank
    FROM vendors_gmv_per_year
)

SELECT
    -- DATE_TRUNC()
    TIMESTAMP(CONCAT(CAST(year AS STRING), '-01-01T00:00:00')) AS year, -- based on expected output in .docx file
    country_name,
    vendor_name,
    total_gmv
FROM ranked_vendors_per_year
WHERE rank <= 2 -- select top 2 vendors for each country and year
ORDER BY year, country_name;
{{
    config(
        materialized='view'
    )
}}

WITH order_years AS (
    -- CTE extracting the year from order dates and summing GMV
    SELECT
        vendors.id AS vendor_id,
        vendors.vendor_name,
        vendors.country_name,
        EXTRACT(YEAR FROM orders.date_local) AS year,
        ROUND(SUM(orders.gmv_local), 2) AS total_gmv
    FROM {{ source('csv_source', 'orders') }} orders
    INNER JOIN {{ source('csv_source', 'vendors') }} vendors ON vendors.id = orders.vendor_id
    GROUP BY vendors.id, vendors.vendor_name, vendors.country_name, year
),

ranked_vendors_per_year AS (
    -- CTE ranking vendors within each country and year by total GMV
    SELECT
        country_name,
        vendor_name,
        year,
        total_gmv,
        ROW_NUMBER() OVER (PARTITION BY country_name, year ORDER BY total_gmv DESC) AS rank
    FROM order_years
)

SELECT
    CAST(MAKEDATE(year, 1) AS TIMESTAMP) AS year,
    country_name,
    vendor_name,
    total_gmv
FROM ranked_vendors_per_year
WHERE rank <= 2 -- select top 2 vendors for each country and year
ORDER BY year, country_name;

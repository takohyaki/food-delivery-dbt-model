{{
    config(
        materialized='view'
    )
}}

WITH vendor_gmv AS (
    -- CTE calculates total GMV for each active vendor and ranks them within their country
    SELECT 
        v.id AS vendor_id,
        v.country_name,
        v.vendor_name,
        ROUND(SUM(o.gmv_local), 2) AS total_gmv,
        ROW_NUMBER() OVER (PARTITION BY v.country_name ORDER BY SUM(o.gmv_local) DESC) AS rank
    FROM {{ source('csv_source', 'vendors') }} v
    JOIN {{ source('csv_source', 'orders') }} o ON v.id = o.vendor_id
    WHERE v.is_active = TRUE
    GROUP BY v.id, v.country_name, v.vendor_name
)

SELECT 
    country_name, 
    vendor_name,
    total_gmv
FROM vendor_gmv
WHERE rank = 1; -- selecting the top vendor in each country

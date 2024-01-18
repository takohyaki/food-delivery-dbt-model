{{
    config(
        materialized='view'
    )
}}

WITH active_vendors AS (
    -- CTE to filter only active vendors
    SELECT 
        id AS vendor_id,
        vendor_name,
        country_name
    FROM {{ source('csv_source', 'vendors') }}
    WHERE is_active = TRUE
),

vendor_gmv AS (
    -- CTE calculates total GMV for each vendor
    SELECT 
        o.vendor_id,
        ROUND(SUM(o.gmv_local), 2) AS total_gmv
    FROM {{ source('csv_source', 'orders') }} o
    WHERE o.vendor_id IN (SELECT vendor_id FROM active_vendors)
    GROUP BY o.vendor_id
),

country_vendor_gmv AS (
    -- CTE combines vendor details with their total GMV
    SELECT 
        av.country_name, 
        av.vendor_name,
        vg.total_gmv
    FROM active_vendors av
    JOIN vendor_gmv vg ON av.vendor_id = vg.vendor_id
),

ranked_vendors AS (
    -- CTE ranks vendors based on total GMV within each country
    SELECT 
        country_name, 
        vendor_name,
        total_gmv,
        ROW_NUMBER() OVER (PARTITION BY country_name ORDER BY total_gmv DESC) AS rank
    FROM country_vendor_gmv
)

SELECT 
    country_name, 
    vendor_name,
    total_gmv
FROM ranked_vendors
WHERE rank = 1; -- selecting the top vendor in each country

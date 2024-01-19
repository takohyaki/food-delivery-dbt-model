{{
    config(
        materialized='view'
    )
}}

WITH taiwan_orders AS (
    -- CTE to get orders related to Taiwanese vendors and calculate total GMV and customer count
    SELECT 
        v.vendor_name,
        COUNT(DISTINCT o.customer_id) AS customer_count,
        ROUND(SUM(o.gmv_local), 2) AS total_gmv
    FROM {{ source('csv_source', 'orders') }} o
    INNER JOIN {{ source('csv_source', 'vendors') }} v ON o.vendor_id = v.id
    WHERE v.country_name = 'Taiwan'
    GROUP BY v.vendor_name
)

SELECT 
    vendor_name,
    customer_count,
    total_gmv
FROM taiwan_orders
ORDER BY customer_count DESC;
{{
    config(
        materialized='view'
    )
}}

WITH taiwan_vendors AS (
    -- CTE to filter Taiwanese vendors
    SELECT 
        id AS vendor_id,
        vendor_name
    FROM {{ source('csv_source', 'vendors') }}
    WHERE country_name = 'Taiwan'
),

taiwan_orders AS (
    -- CTE to get orders related to Taiwanese vendors
    SELECT 
        order_id,
        vendor_id,
        customer_id,
        gmv_local
    FROM {{ source('csv_source', 'orders') }}
    WHERE vendor_id IN (SELECT vendor_id FROM taiwan_vendors)
),

vendor_gmv_customer_count AS (
    -- CTE to calculate total GMV and customer count for each Taiwanese vendor
    SELECT 
        tv.vendor_name,
        COUNT(DISTINCT t.customer_id) AS customer_count,
        ROUND(SUM(t.gmv_local), 2) AS total_gmv
    FROM taiwan_orders t
    INNER JOIN taiwan_vendors tv ON t.vendor_id = tv.vendor_id
    GROUP BY tv.vendor_name
)

SELECT 
    vendor_name,
    customer_count,
    total_gmv
FROM vendor_gmv_customer_count
ORDER BY customer_count DESC;
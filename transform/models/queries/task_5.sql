{{
    config(
        materialized='view'
    )
}}

WITH country_total_gmv AS (
    SELECT
        country_name,
        total_gmv AS country_total_gmv
    FROM {{ ref('total_gmv') }}
),
top_vendor_gmv AS (
    SELECT
        country_name,
        vendor_name,
        total_gmv AS top_vendor_gmv
    FROM {{ ref('top_vendor_by_country') }}
    WHERE rank = 1
)

SELECT
    ctg.country_name,
    tvg.vendor_name,
    tvg.top_vendor_gmv,
    ctg.country_total_gmv,
    CASE
        WHEN ctg.country_total_gmv > 0 THEN (tvg.top_vendor_gmv / ctg.country_total_gmv) * 100
        ELSE 0
    END AS top_vendor_gmv_percentage
FROM top_vendor_gmv tvg
INNER JOIN country_total_gmv ctg ON tvg.country_name = ctg.country_name;

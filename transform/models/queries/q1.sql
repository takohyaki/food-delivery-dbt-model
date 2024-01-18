{{
    config(
        materialized='view'
    )
}}

WITH total_gmv AS (
  -- CTE aggregates the total GMV for each country
  SELECT country_name, ROUND(SUM(gmv_local),2) AS total_gmv
  FROM {{ source('csv_source', 'orders') }}
  GROUP BY country_name
)
SELECT * FROM total_gmv;
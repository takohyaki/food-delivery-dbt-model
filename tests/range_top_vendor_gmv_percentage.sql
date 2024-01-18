-- Tests if top_vendor_gmv_percentage is between 0 and 100
SELECT
    *
FROM {{ model }}
WHERE top_vendor_gmv_percentage < 0 OR top_vendor_gmv_percentage > 100

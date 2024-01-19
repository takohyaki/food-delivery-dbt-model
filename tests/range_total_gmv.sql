-- Tests if total_gmv is greater than or equal to 0
SELECT
    *
FROM {{ model }}
WHERE total_gmv >= 0
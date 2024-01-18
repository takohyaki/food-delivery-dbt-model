-- Tests if rank is either 1 or 2
SELECT
    *
FROM {{ model }}
WHERE rank NOT IN (1, 2)

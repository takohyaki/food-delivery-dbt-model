-- tests/boolean_test.sql

select *
from {{ model }}
where not (
    {{ column.name }} is true or 
    {{ column.name }} is false or 
    {{ column.name }} is null
)
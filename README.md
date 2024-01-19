# Food Delivery DBT Models

This README outlines the approach and structure I took for a project on dbt models. The data contains information on food orders and vendors.

## Approach

### SQL Queries:

- In this part, I focused on writing SQL queries based on two provided datasets: `orders.csv` and `vendors.csv`. From a brief scan, it became evident that orders.csv contains detailed data on individual orders, including foreign keys like vendor_id which link to entries in vendors.csv. This setup implies that `vendors.csv` provides more in-depth information about the vendors themselves, elucidating the sources of various orders and offering a more comprehensive view of the entities involved in fulfilling these orders.

- My Tasks:
1. Total GMV by Country:
   - Aggregated Gross Merchandise Volume (GMV) from orders for each country
   - Grouped data by country_name
   - For all GMV values, I used the ROUND function to 2 decimal places to maintain consistent formatting
2. GMV of Vendors in Taiwan:
   - Filtered vendors to include only Taiwan
   - Retrieved orders linked to these Taiwanese vendors
   - Calculated total GMV and distinct customer count for each vendor
   - Ordered by customer count in descending order
3. Top Active Vendor by GMV in Each Country: 
   - Filtered vendors to include only active ones (boolean type)
   - Calculated total GMV for each vendor
   - Combined vendor details with their respective GMVs
   - Ranked vendors within each country based on GMV
   - Selected the top vendor (rank = 1) in each country
4. Top 2 Vendors Per Country for Each Year:
   - Extracted year from order dates
   - Aggregated GMV for each vendor by year
   - Retrieved vendor details and combined them with their yearly GMV
   - Ranked vendors within each country and year by total GMV
   - Selected top two vendors (rank <= 2) for each country and year
   - Ordered results by year and country

### Building dbt Data Models

- My Steps:
1. Understanding dbt: I went through the dbt documentation, focusing on building my first project and models. I used vscode to write the files and cloned my repository locally.
2. Creating dbt Models: In the transform/models folder, I added new dbt models based on my SQL queries from Part 1. Each model has a corresponding .sql and .yml file. They are under the `transform/model/queries` folder.
3. Writing dbt Models: I ensured that each file was correctly configured. For Task 5, I demonstrated using the ref function by writing a model that returns the top vendor's GMV as a percentage of the total GMV in each country. I referred to the total_gmv (`q1.sql`) and top_vendor_by_country models (`q3.sql`). The query:
   - Calculates total GMV for each country (country_total_gmv)
   - Retrieves GMV for the top-ranked vendor in each country (top_vendor_gmv)
   - Joins these two datasets on country_name
   - Computes each top vendor's GMV as a percentage of their country's total GMV

## Notes on Project
- I added tests into a `tests` folder under `transform`.
- Instead of using direct references (e.g. `from dbt-tutorial.jaffle_shop.customers`), I tuilised dbt's `source` function to reference data in `orders.csv` and `vendors.csv` and created a `sources.yml` file after looking at other dbt projects online. This made it easier to manage and reference them as it centralised the configuration for the datasets and allowed me to apply tests directly onto the raw data.
- For each of the models, they are materialized as a `view` instead of a `table` since the datasets are relatively small and simple.

This project has been a good exercise to demonstrate my SQL querying skills and to learn about dbt modelling. I am open to any feedback/ suggestions on my work!

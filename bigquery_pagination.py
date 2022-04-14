from google.cloud import bigquery

# Construct a BigQuery client object.
client = bigquery.Client()

query = """
    SELECT name, SUM(number) as total_people
    FROM `bigquery-public-data.usa_names.usa_1910_2013`
    GROUP BY name
    ORDER BY total_people DESC
"""
query_job = client.query(query)  # Make an API request.
query_job.result()  # Wait for the query to complete.

# Get the destination table for the query results.
#
# All queries write to a destination table. If a destination table is not
# specified, the BigQuery populates it with a reference to a temporary
# anonymous table after the query completes.
destination = query_job.destination

# Get the schema (and other properties) for the destination table.
#
# A schema is useful for converting from BigQuery types to Python types.
destination = client.get_table(destination)

page_token= None
# Download rows.
#
# The client library automatically handles pagination.
print("The query data:")

rows = client.list_rows(destination, page_size=1000)
curr_page = rows.page_number
items_per_page = 0
for row in rows:
    if curr_page != rows.page_number:
        print(f"flush page: {curr_page}, items_per_page: {items_per_page}")
        curr_page = rows.page_number
        items_per_page = 0
    # print("name={}, count={}".format(row["name"], row["total_people"]))
    items_per_page += 1

print(f"final page: {curr_page}, items_per_page: {items_per_page}")
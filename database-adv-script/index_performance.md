---

# Measuring SQL Query Performance Before and After Indexing

This document outlines the process for measuring the performance impact of adding indexes to your database tables. We will use the `EXPLAIN` or `ANALYZE` command to view and compare the query execution plans.

## Objective
Verify that the `CREATE INDEX` statements from `database_index.sql` improve the performance of relevant queries.

---

## Prerequisites

1. A running database instance with the `users`, `properties`, `bookings`, and `reviews` tables.
2. These tables should contain a *sufficient amount of data*. Indexes typically show significant benefits on tables with thousands or millions of rows. On very small datasets, the impact might be negligible or even slightly negative due to index overhead.
3. The `database_index.sql` file containing the `CREATE INDEX` commands for:
   - `bookings.user_id`
   - `bookings.property_id`
   - `reviews.property_id`
4. A database client tool (like `psql` for PostgreSQL, `mysql` client for MySQL, SQL Server Management Studio, DBeaver, etc.) where you can execute SQL commands and view output.

---

## Key Tools: EXPLAIN / ANALYZE

- **`EXPLAIN <your_query>;`**: This command shows the *query execution plan* that the database optimizer *intends* to use for your query. It provides estimates of cost, rows, and how tables will be accessed (full scan, index scan, etc.) and joined. It does *not* actually run the query or return results.

- **`ANALYZE <your_query>;`**: This command actually *executes* the query and then shows the *actual* execution plan, including real runtime statistics like execution time and actual number of rows processed at each step. This is often more useful for real-world performance measurement, but it takes longer as it runs the query completely.

**Note:** The exact syntax and output format of `EXPLAIN` or `ANALYZE` vary significantly between database systems (PostgreSQL, MySQL, SQL Server, Oracle). You may need to consult your specific database documentation for detailed interpretation. However, the general concepts (scan types, costs, rows) are similar.

---

## Measurement Process

Follow these steps to measure performance before and after adding indexes:

### Step 1: Ensure a Clean State (No Target Indexes Present)

Before measuring the "before" performance, ensure that the specific indexes you plan to add (`idx_bookings_user_id`, `idx_bookings_property_id`, `idx_reviews_property_id`) do not already exist.

If you've run the `database_index.sql` script before, you might need to drop them. The `database_index.sql` file *could* include `DROP INDEX IF EXISTS` statements at the top for convenience, making this step easier to repeat.

```sql
-- Optional: Drop the indexes if they exist to ensure a clean "before" state
-- Use IF EXISTS for databases that support it (e.g., PostgreSQL, MySQL >= 5.1)

-- DROP INDEX IF EXISTS idx_bookings_user_id ON bookings;
-- DROP INDEX IF EXISTS idx_bookings_property_id ON bookings;
-- DROP INDEX IF EXISTS idx_reviews_property_id ON reviews;

-- For SQL Server:
-- IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_bookings_user_id' AND object_id = OBJECT_ID('bookings'))
--     DROP INDEX idx_bookings_user_id ON bookings;
-- ... and so on for the other indexes
```

Run the necessary `DROP INDEX` commands if the indexes exist.

---

### Step 2: Measure Performance Before Indexing

Choose one or more queries that you expect to benefit from the indexes. Good candidates from our previous examples include:
- The `INNER JOIN` query retrieving bookings and users (uses `bookings.user_id`).
- The `LEFT JOIN` query retrieving properties and reviews (uses `reviews.property_id`).
- The correlated subquery finding users with many bookings (uses `bookings.user_id` within the subquery).
- The query ranking properties by booking count (uses `bookings.property_id` in the subquery).

**Example Query:**

```sql
-- Query to test (Inner Join bookings and users)
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id,
    u.username,
    u.email
FROM
    bookings b
INNER JOIN
    users u
ON
    b.user_id = u.user_id;
```

Now, prefix the query with `EXPLAIN` or `ANALYZE` and run it in your database client:

```sql
-- Example using EXPLAIN (shows plan, no execution)
EXPLAIN
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id,
    u.username,
    u.email
FROM
    bookings b
INNER JOIN
    users u
ON
    b.user_id = u.user_id;
```

```sql
-- Example using ANALYZE (executes query and shows plan + actual stats)
-- Use this if you want to see actual execution times
ANALYZE
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id,
    u.username,
    u.email
FROM
    bookings b
INNER JOIN
    users u
ON
    b.user_id = u.user_id;
```

**Action**: Run the `EXPLAIN` or `ANALYZE` command for your chosen query(s). Save the output. This is your baseline performance plan. Look for terms like `Seq Scan`, `Table Scan`, or `Full Scan` on the `bookings` table, indicating it might be reading the entire table. Note the estimated or actual costs/times.

---

### Step 3: Create the Indexes

Now, apply the indexes defined in your `database_index.sql` file. Execute the script against your database.

```bash
# Example using psql (PostgreSQL)
psql -d your_database_name -f database_index.sql

# Example using mysql client (MySQL)
mysql -D your_database_name < database_index.sql

# Example for SQL Server using sqlcmd
sqlcmd -S your_server_name -d your_database_name -i database_index.sql
```

Confirm that the indexes were created successfully (e.g., by checking the database schema or system tables).

---

### Step 4: Measure Performance After Indexing

Run the exact same query(s) you tested in Step 2, again prefixed with `EXPLAIN` or `ANALYZE`.

```sql
-- Run the same query with EXPLAIN again
EXPLAIN
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id,
    u.username,
    u.email
FROM
    bookings b
INNER JOIN
    users u
ON
    b.user_id = u.user_id;
```

```sql
-- Or with ANALYZE again
ANALYZE
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id,
    u.username,
    u.email
FROM
    bookings b
INNER JOIN
    users u
ON
    b.user_id = u.user_id;
```

**Action**: Run the `EXPLAIN` or `ANALYZE` command for your chosen query(s). Save the new output.

---

### Step 5: Compare and Interpret the Results

Now, compare the output from Step 2 ("Before") and Step 4 ("After"). Look for the following indicators of performance improvement:
- **Scan Type Change**: A change from a full table scan (e.g., `Seq Scan`, `Table Scan`) to an index scan (e.g., `Index Scan`, `Index Only Scan`).
- **Reduced Cost**: The estimated cost numbers in the `EXPLAIN` plan should be significantly lower after indexing.
- **Reduced Execution Time**: If you used `ANALYZE`, the actual execution time should decrease, especially for larger datasets.
- **Fewer Rows Examined**: The actual number of rows processed or examined at specific steps of the plan (e.g., table/index scans) should decrease.
- **Join Method Change**: The database might switch to a more efficient join algorithm.

**Expected Outcome**: For the SELECT ... FROM bookings b INNER JOIN users u ON b.user_id = u.user_id; query, after creating idx_bookings_user_id on the bookings table, you should expect to see the database use this index when joining bookings with users. The join operation involving bookings should show an Index Scan on bookings using idx_bookings_user_id, rather than a full table scan on bookings. This should result in a lower estimated cost and faster actual execution time (if using ANALYZE).

---

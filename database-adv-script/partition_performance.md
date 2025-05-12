# Report on Table Partitioning Implementation and Performance

**Objective:** Implement partitioning on the `bookings` table based on `start_date` and evaluate performance improvements for date-range queries.

**Implementation:**

The `bookings` table was partitioned using `RANGE` partitioning on the `start_date` column. Partitions were created for specific monthly ranges (e.g., `bookings_2023_01`, `bookings_2023_02`) and a `MAXVALUE` partition (`bookings_future`) was included to handle future data.

The partitioning script (`partitioning.sql`) involved:
1.  Creating the partitioned parent table `bookings` with `PARTITION BY RANGE (start_date)`.
2.  Creating several child partitions using `CREATE TABLE ... PARTITION OF ... FOR VALUES FROM ... TO ...;`.
3.  (Optionally) Adding indexes on relevant columns (like `start_date`, `user_id`, `property_id`) to the parent table, which are inherited by the partitions in PostgreSQL.

**Performance Testing (using EXPLAIN/ANALYZE):**

Performance testing was conducted using `EXPLAIN (ANALYZE, VERBOSE)` on a dataset large enough to populate multiple partitions.

*   **Query 1: Filtering by a specific date range within a single partition (e.g., `start_date >= '2023-02-01' AND start_date < '2023-03-01'`)**
    *   **Observation:** The `EXPLAIN` plan clearly showed **Partition Pruning**. The database optimizer identified that only the `bookings_2023_02` partition needed to be accessed.
    *   **Result:** Execution time and estimated cost were significantly lower compared to queries accessing the entire table or compared to the expected cost/time on a large unpartitioned table for the same date range filter. The query effectively ran against a much smaller subset of the total data.

*   **Query 2: Filtering by a date range spanning multiple partitions (e.g., `start_date >= '2023-01-15' AND start_date < '2023-03-15'`)**
    *   **Observation:** Partition pruning still occurred (partitions outside the range were excluded), but the plan showed scans on multiple child partitions (`bookings_2023_01`, `bookings_2023_02`, `bookings_2023_03`).
    *   **Result:** Performance was better than scanning the entire table, but slower than Query 1, as expected since more data needed to be accessed across multiple partitions.

*   **Query 3: Filtering on a non-partitioning key column without a date filter (e.g., `WHERE user_id = 123`)**
    *   **Observation:** The `EXPLAIN` plan showed that the database needed to access multiple (or all) partitions to find matches for the `user_id`.
    *   **Result:** Performance improvement for this type of query is less pronounced or non-existent unless secondary indexes on `user_id` are effectively used *within* each scanned partition. This highlights that partitioning primarily benefits queries filtering on the partition key.

**Conclusion:**

Implementing `RANGE` partitioning on the `bookings.start_date` column successfully improved query performance for queries that filter data based on date ranges. The key benefit observed is **partition pruning**, where the database efficiently identifies and scans only the necessary partitions, drastically reducing the amount of data read for date-filtered queries on a large dataset. While partitioning is highly effective for queries aligned with the partition key, its benefits are limited for queries that do not filter on the partitioning column and require scanning data across many partitions. Partitioning also offers advantages for data lifecycle management (e.g., archiving old partitions).

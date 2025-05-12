# Optimization Report

We will assume the following table structure, including a payments table linked to bookings:

### Table Structure:
- **users**: `user_id` (PK), `username`, `email`, ...
- **properties**: `property_id` (PK), `property_name`, `owner_id`, ...
- **bookings**: `booking_id` (PK), `user_id` (FK to users), `property_id` (FK to properties), `start_date`, `end_date`, ...
- **reviews**: `review_id` (PK), `property_id` (FK to properties), `user_id` (FK to users), `rating`, `comment`, ...
- **payments**: `payment_id` (PK), `booking_id` (FK to bookings), `amount`, `payment_date`, `status`, ...

---

### 1. Initial Complex Query

**Objective**: Retrieve all bookings along with the user details, property details, and payment details.

**Explanation**:
This query uses `INNER JOINs` to combine data from four tables: bookings, users, properties, and payments. It selects columns from each table to provide a comprehensive view for every booking that has a matching user, property, and payment record.

```sql
-- Initial complex query to retrieve detailed booking information
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id AS user_id, -- Alias user_id from users table
    u.username,
    u.email,
    p.property_id AS property_id, -- Alias property_id from properties table
    p.property_name,
    pmt.payment_id,
    pmt.amount,
    pmt.payment_date,
    pmt.status AS payment_status -- Alias status from payments table
FROM
    bookings b
INNER JOIN
    users u ON b.user_id = u.user_id         -- Join with users on user_id
INNER JOIN
    properties p ON b.property_id = p.property_id -- Join with properties on property_id
INNER JOIN
    payments pmt ON b.booking_id = pmt.booking_id -- Join with payments on booking_id
ORDER BY
    b.start_date DESC; -- Example ORDER BY clause
```

---

### 2. Analyze the Query's Performance using EXPLAIN/ANALYZE

To analyze the performance, you would use your database's `EXPLAIN` or `ANALYZE` command by prefixing the query with it.

#### Process:
Execute the query with `EXPLAIN` or `ANALYZE`:

```sql
-- Using EXPLAIN (shows plan)
EXPLAIN
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id AS user_id,
    u.username,
    u.email,
    p.property_id AS property_id,
    p.property_name,
    pmt.payment_id,
    pmt.amount,
    pmt.payment_date,
    pmt.status AS payment_status
FROM
    bookings b
INNER JOIN
    users u ON b.user_id = u.user_id
INNER JOIN
    properties p ON b.property_id = p.property_id
INNER JOIN
    payments pmt ON b.booking_id = pmt.booking_id
ORDER BY
    b.start_date DESC;

-- Or using ANALYZE (executes and shows actual stats)
ANALYZE
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id AS user_id,
    u.username,
    u.email,
    p.property_id AS property_id,
    p.property_name,
    pmt.payment_id,
    pmt.amount,
    pmt.payment_date,
    pmt.status AS payment_status
FROM
    bookings b
INNER JOIN
    users u ON b.user_id = u.user_id
INNER JOIN
    properties p ON b.property_id = p.property_id
INNER JOIN
    payments pmt ON b.booking_id = pmt.booking_id
ORDER BY
    b.start_date DESC;
```

#### Interpret the Output:
- **Identify Inefficiencies**: Without proper indexing, common inefficiencies include full table scans (e.g., `Seq Scan`, `Table Scan`) on large tables for joins.

---

### 3. Refactor the Query to Reduce Execution Time

The most effective refactoring for this query involves applying the appropriate indexes.

#### Indexes to Apply:
- `bookings.user_id`
- `bookings.property_id`
- `payments.booking_id`

#### Example Index:
```sql
CREATE INDEX idx_bookings_user_id ON bookings (user_id);
CREATE INDEX idx_bookings_property_id ON bookings (property_id);
CREATE INDEX idx_payments_booking_id ON payments (booking_id);
```

#### Refactored Query:
The query structure remains the same but will now perform much faster due to indexing.

```sql
-- Refactored Query (syntax is the same as initial, performance relies on indexes)
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id AS user_id,
    u.username,
    u.email,
    p.property_id AS property_id,
    p.property_name,
    pmt.payment_id,
    pmt.amount,
    pmt.payment_date,
    pmt.status AS payment_status
FROM
    bookings b
INNER JOIN
    users u ON b.user_id = u.user_id
INNER JOIN
    properties p ON b.property_id = p.property_id
INNER JOIN
    payments pmt ON b.booking_id = pmt.booking_id
ORDER BY
    b.start_date DESC;
```

---

### 4. Performance Comparison

- **Before Indexing**: Look for full table scans and higher execution times.
- **After Indexing**: Expect to see `Index Scan` operations, reduced costs, and improved execution times.

---

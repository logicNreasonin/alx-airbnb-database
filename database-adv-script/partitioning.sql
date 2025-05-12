-- partitioning.sql

-- !!! IMPORTANT: This script assumes you are starting clean or are OK
-- with renaming/dropping the original 'bookings' table.
-- If you have existing data, you would need to carefully migrate it
-- AFTER creating the new partitioned table and its partitions.

-- Optional: Rename the existing bookings table if it has data
-- ALTER TABLE bookings RENAME TO old_bookings;

-- Optional: Drop the existing bookings table if you don't need its data
-- DROP TABLE IF EXISTS bookings CASCADE; -- Use CASCADE with caution!

-- Create the new partitioned bookings table
-- This is the "parent" table definition
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY, -- Or your existing PK definition
    user_id INT NOT NULL,
    property_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    -- Add any other columns from your bookings table
    -- payment_status VARCHAR(50),
    -- total_amount DECIMAL(10, 2),

    -- Define the foreign key constraints on the parent table
    -- Note: FKs on partitioned tables can have complexities,
    -- especially regarding checking against parent/child tables.
    -- Check your DB documentation for specifics.
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (property_id) REFERENCES properties (property_id)
) PARTITION BY RANGE (start_date); -- Specify the partitioning strategy and column

-- Create individual partitions (child tables)
-- We'll create partitions by month for illustrative purposes

-- Partition for January 2023
CREATE TABLE bookings_2023_01 PARTITION OF bookings
FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');

-- Partition for February 2023
CREATE TABLE bookings_2023_02 PARTITION OF bookings
FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');

-- Partition for March 2023
CREATE TABLE bookings_2023_03 PARTITION OF bookings
FOR VALUES FROM ('2023-03-01') TO ('2023-04-01');

-- Add more partitions as needed for historical or future data...
-- Example: Partition for the rest of 2023 (lumping months together)
-- CREATE TABLE bookings_2023_rest PARTITION OF bookings
-- FOR VALUES FROM ('2023-04-01') TO ('2024-01-01');

-- Create a partition for future bookings or data outside defined ranges
-- This is important to avoid errors when inserting data that doesn't fit
CREATE TABLE bookings_future PARTITION OF bookings
FOR VALUES FROM ('2024-01-01') TO (MAXVALUE); -- MAXVALUE captures everything upwards

-- If you had historical data in old_bookings, you would now migrate it:
-- INSERT INTO bookings SELECT * FROM old_bookings;
-- The database automatically directs rows to the correct partition based on start_date.

-- Optional: Add indexes to partitions
-- Indexes on the partitioning key column are often beneficial *within* each partition.
-- Indexes on foreign keys or other frequently queried columns should also be added.
-- In PostgreSQL, indexes created on the parent table are automatically applied to all partitions.
-- CREATE INDEX ON ONLY bookings (start_date); -- Create on parent applies to children
-- CREATE INDEX ON ONLY bookings (user_id);
-- CREATE INDEX ON ONLY bookings (property_id);

-- If using other DBs, you might need to create indexes on each child table explicitly:
-- CREATE INDEX idx_bookings_2023_01_user_id ON bookings_2023_01 (user_id);
-- CREATE INDEX idx_bookings_2023_01_property_id ON bookings_2023_01 (property_id);
-- ... and so on for each partition and necessary column.

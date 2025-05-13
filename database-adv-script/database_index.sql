-- database_index.sql

-- Drop indexes if they exist (Optional, useful for re-running scripts)
-- DROP INDEX IF EXISTS idx_bookings_user_id;
-- DROP INDEX IF EXISTS idx_bookings_property_id;
-- DROP INDEX IF EXISTS idx_reviews_property_id;

-- Create indexes on foreign key columns frequently used in JOINs and WHERE clauses

-- Index for bookings.user_id (improves joins with users, filtering by user)
CREATE INDEX idx_bookings_user_id ON bookings (user_id);

-- Index for bookings.property_id (improves joins with properties, filtering by property)
CREATE INDEX idx_bookings_property_id ON bookings (property_id);

-- Index for reviews.property_id (improves joins with properties, grouping/filtering by property)
CREATE INDEX idx_reviews_property_id ON reviews (property_id);

-- Optional: Index on reviews.user_id if you frequently query reviews by user
-- CREATE INDEX idx_reviews_user_id ON reviews (user_id);

-- Note: Primary keys (user_id, property_id, booking_id, review_id) are
-- typically automatically indexed by the database system.

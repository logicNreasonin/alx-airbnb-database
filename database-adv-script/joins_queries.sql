-- Retrieve bookings and the users who made them.
-- Only rows where a booking has a matching user (and vice versa) are returned.
SELECT
    b.booking_id,
    b.start_date,
    b.end_date,
    u.user_id,
    u.username,
    u.email
FROM
    bookings b  -- Start with the bookings table (aliased as 'b')
INNER JOIN
    users u     -- Join with the users table (aliased as 'u')
ON
    b.user_id = u.user_id; -- The join condition: linking booking's user_id to user's user_id

-- Retrieve all properties and their reviews.
-- Includes properties that have no reviews (reviews columns will be NULL for those).
-- All rows from the LEFT table (properties) are included.
SELECT
    p.property_id,
    p.property_name,
    r.review_id,
    r.rating,
    r.comment
FROM
    properties p  -- Start with the properties table (aliased as 'p') - This is the LEFT table
LEFT JOIN     -- Join with the reviews table (aliased as 'r') - This is the RIGHT table
    reviews r
ON
    p.property_id = r.property_id; -- The join condition: linking property_id

-- Retrieve all users and all bookings.
-- Includes users with no bookings and bookings not linked to a user (if any exist).
-- Rows from BOTH the LEFT (users) and RIGHT (bookings) tables are included.
SELECT
    u.user_id,
    u.username,
    b.booking_id,
    b.start_date,
    b.end_date
FROM
    users u     -- Start with the users table (aliased as 'u') - This is the LEFT table
FULL OUTER JOIN -- Join with the bookings table (aliased as 'b') - This is the RIGHT table
    bookings b
ON
    u.user_id = b.user_id; -- The join condition: linking user_id

/*
-- If using MySQL, you would simulate FULL OUTER JOIN like this:
SELECT
    u.user_id,
    u.username,
    b.booking_id,
    b.start_date,
    b.end_date
FROM
    users u
LEFT JOIN
    bookings b ON u.user_id = b.user_id

UNION -- UNION combines the results and removes duplicates

SELECT
    u.user_id,
    u.username,
    b.booking_id,
    b.start_date,
    b.end_date
FROM
    users u
RIGHT JOIN
    bookings b ON u.user_id = b.user_id
WHERE u.user_id IS NULL; -- This WHERE clause is important to only include the unmatched rows from the RIGHT JOIN,
                         -- as the matching rows are already included by the LEFT JOIN part before the UNION.
                         -- However, often just UNIONing LEFT and RIGHT JOIN is sufficient depending on exact needs.
                         -- A simpler approach for FULL OUTER JOIN in MySQL is often just UNIONing LEFT and RIGHT JOIN:
-- SELECT ... FROM users u LEFT JOIN bookings b ON u.user_id = b.user_id
-- UNION
-- SELECT ... FROM users u RIGHT JOIN bookings b ON u.user_id = b.user_id;
-- This simpler UNION approach includes matching rows twice internally before UNION removes duplicates,
-- but is easier to write and often performs fine.
*/

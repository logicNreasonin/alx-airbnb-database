-- performance.sql

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

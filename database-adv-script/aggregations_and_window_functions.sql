-- Retrieve the total number of bookings for each user.
SELECT
    u.user_id,
    u.username,
    COUNT(b.booking_id) AS total_bookings -- Count the bookings
FROM
    users u
JOIN
    bookings b ON u.user_id = b.user_id -- Join users and bookings
GROUP BY
    u.user_id, u.username -- Group results by user
ORDER BY
    total_bookings DESC; -- Optional: Order by the number of bookings

-- Calculate total bookings per property and then rank properties based on that count.
SELECT
    p.property_id,
    p.property_name,
    booking_counts.booking_count,
    RANK() OVER (ORDER BY booking_counts.booking_count DESC) AS property_rank, -- Assigns a rank, allowing ties
    ROW_NUMBER() OVER (ORDER BY booking_counts.booking_count DESC) AS property_row_number -- Assigns a unique sequential number
FROM
    properties p
JOIN
    (
        -- Subquery to calculate total bookings per property
        SELECT
            property_id,
            COUNT(booking_id) AS booking_count
        FROM
            bookings
        GROUP BY
            property_id
    ) AS booking_counts ON p.property_id = booking_counts.property_id -- Join properties with the aggregated counts
ORDER BY
    booking_counts.booking_count DESC; -- Order the final result by booking count

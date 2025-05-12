-- Retrieve properties where the average rating is greater than 4.0
-- Uses a non-correlated subquery in the WHERE clause with IN
SELECT
    p.property_id,
    p.property_name
FROM
    properties p
WHERE
    p.property_id IN (
        -- This subquery finds the property_ids that have an average rating > 4.0
        -- It can run independently of the outer query
        SELECT
            r.property_id
        FROM
            reviews r
        GROUP BY
            r.property_id
        HAVING
            AVG(r.rating) > 4.0
    );

-- Retrieve users who have made more than 3 bookings
-- Uses a correlated subquery in the WHERE clause
SELECT
    u.user_id,
    u.username
FROM
    users u -- Alias the outer table so the inner query can reference it
WHERE
    (
        -- This correlated subquery counts the number of bookings
        -- for the SPECIFIC user (u) currently being processed by the outer query.
        -- It references 'u.user_id' from the outer query.
        SELECT
            COUNT(*)
        FROM
            bookings b
        WHERE
            b.user_id = u.user_id
    ) > 3; -- Filter the outer results based on the count returned by the subquery for each user

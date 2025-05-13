-- SQL Script to Populate the Airbnb Clone Database with Sample Data
-- Assumes the database schema (tables, columns, constraints) has already been created.
-- Ensure you are connected to the correct database before running this script.

-- USE your_database_name; -- Uncomment and replace with your actual database name if needed

-- -----------------------------------------------------------------------------
-- Insert Sample Users (Guests, Hosts, and Admins)
-- Passwords should be hashed in a real application, using plain text here for simplicity
-- -----------------------------------------------------------------------------
INSERT INTO Users (username, password, email, role, first_name, last_name, profile_photo_url) VALUES
('alice_guest', 'hashed_password_1', 'alice.guest@example.com', 'guest', 'Alice', 'Guest', 'http://example.com/photos/alice.jpg'),
('bob_host', 'hashed_password_2', 'bob.host@example.com', 'host', 'Bob', 'Host', 'http://example.com/photos/bob.jpg'),
('charlie_admin', 'hashed_password_3', 'charlie.admin@example.com', 'admin', 'Charlie', 'Admin', 'http://example.com/photos/charlie.jpg'),
('diana_host', 'hashed_password_4', 'diana.host@example.com', 'host', 'Diana', 'Host', 'http://example.com/photos/diana.jpg'),
('eve_guest', 'hashed_password_5', 'eve.guest@example.com', 'guest', 'Eve', 'Guest', 'http://example.com/photos/eve.jpg');

-- -----------------------------------------------------------------------------
-- Insert Sample Amenities
-- -----------------------------------------------------------------------------
INSERT INTO Amenities (name) VALUES
('Wifi'),
('Pool'),
('Air Conditioning'),
('Kitchen'),
('Free Parking'),
('Pet Friendly');

-- -----------------------------------------------------------------------------
-- Insert Sample Properties (Owned by Hosts)
-- Assuming User IDs 2 (Bob) and 4 (Diana) are hosts
-- -----------------------------------------------------------------------------
INSERT INTO Properties (host_id, title, description, location, price_per_night, availability_status, bedrooms, bathrooms, max_guests) VALUES
(2, 'Cozy Downtown Apartment', 'A lovely apartment in the heart of the city.', 'New York, NY', 150.00, 'available', 1, 1, 2),
(2, 'Spacious Suburban House', 'Perfect for families, with a large backyard.', 'Los Angeles, CA', 300.00, 'available', 3, 2, 6),
(4, 'Beachfront Bungalow', 'Wake up to the sound of the ocean.', 'Miami, FL', 400.00, 'available', 2, 2, 4),
(4, 'Mountain Cabin Retreat', 'Escape the city in this rustic cabin.', 'Denver, CO', 200.00, 'available', 2, 1, 4);

-- -----------------------------------------------------------------------------
-- Link Properties to Amenities (PropertyAmenity)
-- Assuming Property IDs 1-4 and Amenity IDs 1-6
-- Example: Property 1 has Wifi, AC, Kitchen
-- Example: Property 2 has Wifi, Pool, Free Parking, Kitchen
-- Example: Property 3 has Wifi, Pool, AC, Pet Friendly
-- Example: Property 4 has Wifi, Free Parking, Kitchen, Pet Friendly
-- -----------------------------------------------------------------------------
INSERT INTO PropertyAmenity (property_id, amenity_id) VALUES
(1, 1), (1, 3), (1, 4),
(2, 1), (2, 2), (2, 5), (2, 4),
(3, 1), (3, 2), (3, 3), (3, 6),
(4, 1), (4, 5), (4, 4), (4, 6);

-- -----------------------------------------------------------------------------
-- Insert Sample Bookings (Made by Guests for Properties)
-- Assuming User IDs 1 (Alice) and 5 (Eve) are guests
-- Assuming Property IDs 1-4
-- -----------------------------------------------------------------------------
INSERT INTO Bookings (guest_id, property_id, start_date, end_date, total_price, booking_status) VALUES
(1, 1, '2025-08-10', '2025-08-15', 750.00, 'confirmed'), -- Alice booked Property 1
(5, 3, '2025-09-01', '2025-09-07', 2400.00, 'confirmed'), -- Eve booked Property 3
(1, 2, '2025-10-05', '2025-10-08', 900.00, 'completed'), -- Alice booked Property 2 (completed)
(5, 4, '2025-11-20', '2025-11-25', 1000.00, 'pending'); -- Eve booked Property 4 (pending)

-- -----------------------------------------------------------------------------
-- Insert Sample Payments (Linked to Bookings)
-- Assuming Booking IDs 1-4
-- -----------------------------------------------------------------------------
INSERT INTO Payments (booking_id, amount, currency, payment_method, transaction_id, status, timestamp) VALUES
(1, 750.00, 'USD', 'Credit Card', 'txn_abc123', 'paid', '2025-07-20 10:00:00'),
(2, 2400.00, 'USD', 'PayPal', 'txn_def456', 'paid', '2025-08-15 14:30:00'),
(3, 900.00, 'USD', 'Credit Card', 'txn_ghi789', 'paid', '2025-09-20 09:00:00'), -- Payment for completed booking
(4, 1000.00, 'USD', 'Credit Card', 'txn_jkl012', 'pending', '2025-11-01 11:00:00'); -- Payment for pending booking

-- -----------------------------------------------------------------------------
-- Insert Sample Reviews (Linked to Completed Bookings, User, and Property)
-- Assuming Booking ID 3 is a completed booking by User 1 for Property 2
-- -----------------------------------------------------------------------------
INSERT INTO Reviews (booking_id, guest_id, property_id, rating, comment, date) VALUES
(3, 1, 2, 5, 'Great stay, exactly as described!', '2025-10-09'); -- Alice reviewed Property 2 after Booking 3

-- -----------------------------------------------------------------------------
-- Insert Sample Notifications (Sent to Users)
-- Assuming User IDs 1 (Alice), 2 (Bob), 5 (Eve)
-- -----------------------------------------------------------------------------
INSERT INTO Notifications (user_id, message, type, status, timestamp) VALUES
(1, 'Your booking for Cozy Downtown Apartment is confirmed!', 'email', 'sent', '2025-07-20 10:05:00'),
(2, 'New booking received for Spacious Suburban House.', 'in-app', 'unread', '2025-10-05 08:00:00'), -- Notification to host Bob
(5, 'Please complete payment for your booking at Mountain Cabin Retreat.', 'email', 'sent', '2025-11-01 11:05:00');

-- -----------------------------------------------------------------------------
-- End of script
-- -----------------------------------------------------------------------------

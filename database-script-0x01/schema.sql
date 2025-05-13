-- Airbnb Clone Database Schema
-- Normalized to 3NF with appropriate constraints and indexes

-- Enable UUID extension for unique identifiers (PostgreSQL specific)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create USER table
CREATE TABLE "user" (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    profile_photo VARCHAR(255),
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('guest', 'host', 'admin')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create index on email for faster login queries
CREATE INDEX idx_user_email ON "user"(email);
CREATE INDEX idx_user_type ON "user"(user_type);

-- Create LOCATION table (extracted from PROPERTY for normalization)
CREATE TABLE location (
    location_id SERIAL PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    -- Optional: Add geographic coordinates for map features
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8)
);

-- Create indexes for location searches
CREATE INDEX idx_location_city ON location(city);
CREATE INDEX idx_location_country ON location(country);
CREATE INDEX idx_location_state ON location(state);

-- Create PROPERTY table
CREATE TABLE property (
    property_id SERIAL PRIMARY KEY,
    host_id INTEGER NOT NULL,
    location_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL CHECK (price_per_night > 0),
    max_guests INTEGER NOT NULL CHECK (max_guests > 0),
    bedrooms INTEGER NOT NULL CHECK (bedrooms >= 0),
    bathrooms INTEGER NOT NULL CHECK (bathrooms >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES location(location_id) ON DELETE RESTRICT
);

-- Create indexes for property searches
CREATE INDEX idx_property_host ON property(host_id);
CREATE INDEX idx_property_location ON property(location_id);
CREATE INDEX idx_property_price ON property(price_per_night);
CREATE INDEX idx_property_guests ON property(max_guests);
CREATE INDEX idx_property_active ON property(is_active);

-- Create AMENITY table
CREATE TABLE amenity (
    amenity_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Create PROPERTY_AMENITY junction table
CREATE TABLE property_amenity (
    property_id INTEGER NOT NULL,
    amenity_id INTEGER NOT NULL,
    PRIMARY KEY (property_id, amenity_id),
    FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES amenity(amenity_id) ON DELETE CASCADE
);

-- Create index on junction table for faster lookups
CREATE INDEX idx_property_amenity_property ON property_amenity(property_id);
CREATE INDEX idx_property_amenity_amenity ON property_amenity(amenity_id);

-- Create PROPERTY_IMAGE table
CREATE TABLE property_image (
    image_id SERIAL PRIMARY KEY,
    property_id INTEGER NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    caption TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE
);

-- Create index for faster image retrieval by property
CREATE INDEX idx_property_image_property ON property_image(property_id);

-- Create BOOKING table
CREATE TABLE booking (
    booking_id SERIAL PRIMARY KEY,
    guest_id INTEGER NOT NULL,
    property_id INTEGER NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    guests_count INTEGER NOT NULL CHECK (guests_count > 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'canceled', 'completed')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES property(property_id) ON DELETE CASCADE,
    -- Ensure check-out is after check-in
    CONSTRAINT valid_date_range CHECK (check_out_date > check_in_date)
);

-- Create indexes for booking lookups
CREATE INDEX idx_booking_guest ON booking(guest_id);
CREATE INDEX idx_booking_property ON booking(property_id);
CREATE INDEX idx_booking_dates ON booking(check_in_date, check_out_date);
CREATE INDEX idx_booking_status ON booking(status);

-- Create a function to check for booking conflicts
CREATE OR REPLACE FUNCTION check_booking_conflict()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there's an overlap with existing bookings for the same property
    IF EXISTS (
        SELECT 1 FROM booking
        WHERE property_id = NEW.property_id
        AND status IN ('pending', 'confirmed')
        AND booking_id != NEW.booking_id
        AND (
            (NEW.check_in_date <= check_out_date AND NEW.check_out_date >= check_in_date)
        )
    ) THEN
        RAISE EXCEPTION 'Booking dates conflict with an existing booking for this property';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to prevent booking conflicts
CREATE TRIGGER prevent_booking_conflict
BEFORE INSERT OR UPDATE ON booking
FOR EACH ROW EXECUTE FUNCTION check_booking_conflict();

-- Create PAYMENT table
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    payment_status VARCHAR(20) NOT NULL CHECK (payment_status IN ('pending', 'completed', 'refunded', 'failed')),
    transaction_id VARCHAR(255),
    payment_method VARCHAR(50) NOT NULL,
    payment_date TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE
);

-- Create indexes for payment tracking
CREATE INDEX idx_payment_status ON payment(payment_status);
CREATE INDEX idx_payment_date ON payment(payment_date);

-- Create REVIEW table (simplified with normalized design)
CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL UNIQUE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE
);

-- Create index for linking reviews to properties (via booking)
CREATE INDEX idx_review_booking ON review(booking_id);

-- Create a view for easier access to review data with property and guest info
CREATE VIEW review_details AS
SELECT 
    r.review_id,
    r.booking_id,
    b.property_id,
    p.title AS property_title,
    b.guest_id,
    u.first_name AS guest_first_name,
    u.last_name AS guest_last_name,
    r.rating,
    r.comment,
    r.created_at
FROM review r
JOIN booking b ON r.booking_id = b.booking_id
JOIN property p ON b.property_id = p.property_id
JOIN "user" u ON b.guest_id = u.user_id;

-- Create NOTIFICATION table
CREATE TABLE notification (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    notification_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE
);

-- Create indexes for notification queries
CREATE INDEX idx_notification_user ON notification(user_id);
CREATE INDEX idx_notification_read ON notification(is_read);
CREATE INDEX idx_notification_type ON notification(notification_type);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update the updated_at timestamps
CREATE TRIGGER update_user_modtime
BEFORE UPDATE ON "user"
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_property_modtime
BEFORE UPDATE ON property
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_booking_modtime
BEFORE UPDATE ON booking
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_review_modtime
BEFORE UPDATE ON review
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- Create a materialized view for property search results with average ratings
CREATE MATERIALIZED VIEW property_search AS
SELECT 
    p.property_id,
    p.title,
    p.price_per_night,
    p.max_guests,
    p.bedrooms,
    p.bathrooms,
    p.is_active,
    l.city,
    l.state,
    l.country,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM property p
JOIN location l ON p.location_id = l.location_id
LEFT JOIN booking b ON p.property_id = b.property_id
LEFT JOIN review r ON b.booking_id = r.booking_id
WHERE p.is_active = TRUE
GROUP BY p.property_id, l.city, l.state, l.country;

-- Create index on materialized view for faster searches
CREATE INDEX idx_property_search_city ON property_search(city);
CREATE INDEX idx_property_search_country ON property_search(country);
CREATE INDEX idx_property_search_price ON property_search(price_per_night);
CREATE INDEX idx_property_search_guests ON property_search(max_guests);
CREATE INDEX idx_property_search_rating ON property_search(avg_rating);

-- Create a function to refresh the materialized view
CREATE OR REPLACE FUNCTION refresh_property_search()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY property_search;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to refresh the materialized view when data changes
CREATE TRIGGER refresh_property_search_on_property_change
AFTER INSERT OR UPDATE OR DELETE ON property
FOR EACH STATEMENT EXECUTE FUNCTION refresh_property_search();

CREATE TRIGGER refresh_property_search_on_review_change
AFTER INSERT OR UPDATE OR DELETE ON review
FOR EACH STATEMENT EXECUTE FUNCTION refresh_property_search();

-- Insert some initial amenities
INSERT INTO amenity (name, description) VALUES
('WiFi', 'High-speed wireless internet'),
('Kitchen', 'Full kitchen with appliances'),
('Free parking', 'Free on-premises parking'),
('Pool', 'Swimming pool'),
('Air conditioning', 'Climate control system'),
('Heating', 'Heating system for cold weather'),
('Washer', 'Clothes washing machine'),
('Dryer', 'Clothes dryer'),
('TV', 'Television with standard cable'),
('Workspace', 'Dedicated workspace for laptops'),
('Pet friendly', 'Allows pets on property');

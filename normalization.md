![Airbnb ER Diagram to 3NF](recommendations1.jpg)

Airbnb Clone Database Normalization to 3NF
Introduction
This document explains the normalization process applied to the Airbnb Clone database schema to achieve Third Normal Form (3NF). Database normalization is a systematic approach to organizing data in a relational database that eliminates redundancy and ensures data integrity. Our goal was to transform the initial database design into a structure that satisfies the requirements of 3NF while maintaining all the functionality specified in the project requirements.
Normalization Overview
First Normal Form (1NF)

Each table has a primary key
Each column contains atomic values
No repeating groups or arrays

Second Normal Form (2NF)

Meets all requirements of 1NF
All non-key attributes fully depend on the entire primary key
No partial dependencies

Third Normal Form (3NF)

Meets all requirements of 2NF
No transitive dependencies (non-key attributes must not depend on other non-key attributes)

Initial Schema Assessment
Our initial schema included the following tables:

USER
PROPERTY
PROPERTY_AMENITY
AMENITY
PROPERTY_IMAGE
BOOKING
PAYMENT
REVIEW
NOTIFICATION

Upon analysis, we identified several areas that needed improvement to fully comply with Third Normal Form:
Identified Normalization Issues
1. Location Data in PROPERTY Table
Issue: The PROPERTY table contained several location-related fields (address, city, state, country, zip_code) that formed a logically related group of data. This created potential redundancy if multiple properties exist at the same address or location (e.g., apartments in the same building).
Normalization Principle Violated: This represents a potential transitive dependency, where non-key attributes (location data) could be dependent on a logical concept (location) rather than directly on the primary key (property_id).
2. Redundant Foreign Keys in REVIEW Table
Issue: The REVIEW table contained foreign keys for booking_id, guest_id, and property_id. Since a booking already contains references to both guest and property, this creates redundancy and potential inconsistency.
Normalization Principle Violated: This violates 3NF by introducing redundant dependencies, as guest_id and property_id can be derived from booking_id.
3. Derived Attribute in BOOKING Table
Consideration: The total_price attribute in the BOOKING table could be calculated from price_per_night, the number of nights stayed, and any additional fees.
Analysis: While this could be considered a derived attribute, there are legitimate reasons to store this value directly:

Price serves as a historical record (property prices may change over time)
Special rates or discounts may apply that differ from the standard calculation
Performance benefits for financial reporting

Normalization Steps Applied
Step 1: Extract Location Information to a New Table
Before Normalization:
PROPERTY (
    property_id PK,
    host_id FK,
    title,
    description,
    address,
    city,
    state,
    country,
    zip_code,
    price_per_night,
    max_guests,
    bedrooms,
    bathrooms,
    is_active,
    created_at,
    updated_at
)
After Normalization:
LOCATION (
    location_id PK,
    address,
    city,
    state,
    country,
    zip_code
)

PROPERTY (
    property_id PK,
    host_id FK,
    location_id FK,
    title,
    description,
    price_per_night,
    max_guests,
    bedrooms,
    bathrooms,
    is_active,
    created_at,
    updated_at
)
Rationale:

Creates a dedicated entity for location data that can be referenced by multiple properties
Eliminates potential redundancy when multiple properties share the same address
Facilitates easier updates to location information
Improves data consistency across the system
Allows for future expansion of location-based features

Step 2: Remove Redundant Foreign Keys from REVIEW Table
Before Normalization:
REVIEW (
    review_id PK,
    booking_id FK,
    guest_id FK,
    property_id FK,
    rating,
    comment,
    created_at,
    updated_at
)
After Normalization:
REVIEW (
    review_id PK,
    booking_id FK,
    rating,
    comment,
    created_at,
    updated_at
)
Rationale:

Eliminates redundancy since guest_id and property_id can be obtained through the BOOKING table
Reduces the risk of data inconsistency (e.g., a review referring to a different property than its booking)
Ensures that reviews are always tied to a legitimate booking
Simplifies data integrity constraints

Step 3: Analysis of Derived Attributes
We carefully considered the total_price attribute in the BOOKING table:
Decision: Retain total_price as an explicit attribute.
Rationale:

Historical Value: It preserves the actual amount charged at the time of booking, even if the property's nightly rate changes later.
Special Pricing: It accommodates special rates, discounts, additional fees, or seasonal pricing that may not follow a simple calculation.
Data Integrity: It provides a single source of truth for financial records and reporting.
Performance: It optimizes queries related to financial reporting by avoiding the need to recalculate this value.

Updated Schema After Normalization
After applying these normalization steps, our database schema now includes:

USER (unchanged)
LOCATION (new)
PROPERTY (modified to reference LOCATION)
PROPERTY_AMENITY (unchanged)
AMENITY (unchanged)
PROPERTY_IMAGE (unchanged)
BOOKING (unchanged)
PAYMENT (unchanged)
REVIEW (simplified to remove redundant foreign keys)
NOTIFICATION (unchanged)

Entity Relationship Diagram After Normalization
The updated ER diagram illustrates the changes made during normalization, particularly:

The new LOCATION entity and its relationship to PROPERTY
The simplified REVIEW entity with only the necessary booking_id foreign key
All other relationships remain intact as they were already well-normalized

Benefits of the Normalized Design
The normalized schema now offers several advantages:

Reduced Data Redundancy

Location data stored only once, regardless of how many properties share it
No duplicate foreign key relationships in the REVIEW table


Improved Data Integrity

Updating an address updates it for all properties at that location
Reviews are guaranteed to be consistent with their associated bookings
Changes to property information don't affect historical booking records


Better Data Organization

Logical grouping of related attributes (location data)
Clearer entity relationships with minimized redundancy


Enhanced Extensibility

Location table can be extended with additional attributes (e.g., geographic coordinates, neighborhood information, proximity to amenities)
Easier to implement new features like location-based searching or clustering


Query Optimization

More efficient joins for complex queries
Smaller table sizes for frequently accessed data



Conclusion
The normalization process successfully transformed the initial Airbnb Clone database schema into Third Normal Form. By extracting the LOCATION entity and simplifying the REVIEW entity, we've eliminated transitive dependencies and redundant relationships while preserving all the functionality required by the application.
The resulting schema provides a solid foundation for building a robust, scalable, and maintainable Airbnb Clone system with good data integrity and minimal redundancy.

-- Remove existing tables
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Users;

-- Users Table
CREATE TABLE Users (
    user_id SERIAL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),

    PRIMARY KEY (user_id),

    CHECK (role IN ('Football Fan', 'Ticket Manager'))
);

-- Matches Table
CREATE TABLE Matches (
    match_id SERIAL,
    fixture VARCHAR(150) NOT NULL,
    tournament_category VARCHAR(100) NOT NULL,
    base_ticket_price NUMERIC(10,2) NOT NULL,
    match_status VARCHAR(30) NOT NULL,

    PRIMARY KEY (match_id),

    CHECK (base_ticket_price >= 0),

    CHECK (
        match_status IN (
            'Available',
            'Selling Fast',
            'Sold Out',
            'Postponed'
        )
    )
);

-- Bookings Table
CREATE TABLE Bookings (
    booking_id SERIAL,
    user_id INT NOT NULL,
    match_id INT NOT NULL,
    seat_number VARCHAR(20),
    payment_status VARCHAR(20),
    total_cost NUMERIC(10,2) NOT NULL,

    PRIMARY KEY (booking_id),

    FOREIGN KEY (user_id)
        REFERENCES Users(user_id),

    FOREIGN KEY (match_id)
        REFERENCES Matches(match_id),

    CHECK (total_cost >= 0),

    CHECK (
        payment_status IS NULL
        OR payment_status IN (
            'Pending',
            'Confirmed',
            'Cancelled',
            'Refunded'
        )
    )
);

-- Query 1: Retrieve all upcoming football matches belonging to the 'Champions League' where the match status is 'Available'.
SELECT
    match_id,
    fixture,
    base_ticket_price
FROM Matches
WHERE tournament_category = 'Champions League'
  AND match_status = 'Available';


-- Query 2: Search for all users whose full names start with 'Tanvir' or contain the phrase 'Haque' (case-insensitive).
SELECT
    user_id,
    full_name,
    email
FROM Users
WHERE full_name ILIKE 'Tanvir%'
   OR full_name ILIKE '%Haque%';


-- Query 3: Retrieve all booking records where the payment status is missing (NULL), replacing the empty result with 'Action Required'.
SELECT

booking_id,
user_id,
match_id,

COALESCE(payment_status,'Action Required')
AS systematic_status

FROM Bookings

WHERE payment_status IS NULL;

-- Query 4: Retrieve match booking details along with the User's full name and the scheduled Match fixture teams.
SELECT

b.booking_id,
u.full_name,
m.fixture,
b.total_cost


FROM Bookings b

INNER JOIN Users u

ON b.user_id=u.user_id


INNER JOIN Matches m

ON b.match_id=m.match_id;


-- Query 5: Display a comprehensive list of all users and their booking IDs, ensuring that fans who have never bought a ticket are still listed.
SELECT

u.user_id,
u.full_name,
b.booking_id


FROM Users u

LEFT JOIN Bookings b

ON u.user_id=b.user_id;


-- Query 6: Find all ticket bookings where the total cost is strictly higher than the average cost of all ticket bookings.
SELECT

booking_id,
match_id,
total_cost


FROM Bookings


WHERE total_cost >

(
SELECT AVG(total_cost)
FROM Bookings
);


-- Query 7: Retrieve the top 2 most expensive matches sorted by base ticket price, skipping the absolute highest premium match.
SELECT

match_id,
fixture,
base_ticket_price


FROM Matches


ORDER BY base_ticket_price DESC

OFFSET 1

LIMIT 2;






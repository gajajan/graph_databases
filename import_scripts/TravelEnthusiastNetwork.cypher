// clear all data
MATCH (n)
DETACH DELETE n;

CREATE CONSTRAINT User_id_nodekey IF NOT EXISTS
FOR (u:User)
REQUIRE u.userId IS NODE KEY;

CREATE CONSTRAINT Journey_id_nodekey IF NOT EXISTS
FOR (j:Journey)
REQUIRE j.journeyId IS NODE KEY;

CREATE CONSTRAINT Destination_id_nodekey IF NOT EXISTS
FOR (d:Destination)
REQUIRE d.destinationId IS NODE KEY;

CREATE CONSTRAINT Country_code_nodekey IF NOT EXISTS
FOR (c:Country)
REQUIRE c.countryCode IS NODE KEY;

CREATE CONSTRAINT TravelActivity_name_nodekey IF NOT EXISTS
FOR (a:TravelActivity)
REQUIRE a.activityName IS NODE KEY;

CREATE CONSTRAINT Rating_id_nodekey IF NOT EXISTS
FOR (r:Rating)
REQUIRE r.ratingId IS NODE KEY;

CREATE CONSTRAINT User_firstname_exists IF NOT EXISTS
FOR (u:User)
REQUIRE u.firstname IS NOT NULL;

CREATE CONSTRAINT User_lastname_exists IF NOT EXISTS
FOR (u:User)
REQUIRE u.lastname IS NOT NULL;

CREATE CONSTRAINT Destination_name_exists IF NOT EXISTS
FOR (d:Destination)
REQUIRE d.destinationName IS NOT NULL;

// load vertices
LOAD CSV WITH HEADERS
FROM 'file:///users.csv' AS row
MERGE (u:User {userId: toInteger(row.user_id)})
SET 
u.firstname = row.firstname, 
u.lastname = row.lastname;

LOAD CSV WITH HEADERS
FROM 'file:///journeys.csv' AS row
MERGE (j:Journey {journeyId: toInteger(row.journey_id)})
SET 
j.journeyName = row.journey_name,
j.journeyStart = date(row.journey_start),
j.journeyEnd = date(row.journey_end);

LOAD CSV WITH HEADERS
FROM 'file:///destinations.csv' AS row
MERGE (d:Destination {destinationId: toInteger(row.destination_id)}) 
SET
d.destinationName = row.destination_name;

LOAD CSV WITH HEADERS
FROM 'file:///countries.csv' AS row
MERGE (c:Country{countryCode: row.country_code})
SET
c.countryName = row.country_name;

LOAD CSV WITH HEADERS
FROM 'file:///activities.csv' AS row
MERGE (:TravelActivity {activityName: row.activity_name});

LOAD CSV WITH HEADERS
FROM 'file:///ratings.csv' AS row
MERGE (r:Rating {ratingId: toInteger(row.rating_id)})
SET
r.body = row.body,
r.rating = toInteger(row.rating);

//load edges
LOAD CSV WITH HEADERS
FROM 'file:///follows.csv' AS row
MATCH (u1:User {userId: toInteger(row.user1_id)})
MATCH (u2:User {userId: toInteger(row.user2_id)})
MERGE (u1)-[:FOLLOWS]->(u2);

LOAD CSV WITH HEADERS
FROM 'file:///is_within.csv' AS row
MATCH (d:Destination {destinationId: row.destination_id})
MATCH (c:Country {countryCode: row.country_code})
MERGE (d)-[:IS_WITHIN]->(c);

LOAD CSV WITH HEADERS
FROM 'file:///led_to.csv' AS row
MATCH (j:Journey {journeyId: toInteger(row.journey_id)})
MATCH (d:Destination {destinationId: row.destination_id})
MERGE (j)-[e:LED_TO]->(d)
SET
e.startDate = date(row.start_date),
e.endDate = date(row.end_date);

LOAD CSV WITH HEADERS
FROM 'file:///likes.csv' AS row
MATCH (u:User {userId: toInteger(row.user_id)})
MATCH (a:TravelActivity {activityName: row.activity_name})
MERGE (u)-[:LIKES]->(a);

LOAD CSV WITH HEADERS
FROM 'file:///lives_in.csv' AS row
MATCH (u:User {user_id: toInteger(row.user_id)})
MATCH (c:Country {countryCode: row.country_code})
MERGE (u)-[:LIVES_IN]->(c);

LOAD CSV WITH HEADERS
FROM 'file:///offers.csv' AS row
MATCH (d:Destination {destinationId: row.destination_id})
MATCH (a:TravelActivity {activityName: row.activity_name})
MERGE (d)-[:OFFERS]->(a);

LOAD CSV WITH HEADERS
FROM 'file:///participated.csv' AS row
MATCH (u:User {userId: toInteger(row.user_id)})
MATCH (j:Journey {journeyId: toInteger(row.journey_id)})
MERGE (u)-[:PARTICIPATED]->(j);

LOAD CSV WITH HEADERS
FROM 'file:///wrote_about.csv' AS row
MATCH (u:User {userId: toInteger(row.user_id)})
MATCH (r:Rating {ratingId: toInteger(row.rating_id)})
MATCH (j:Journey {journeyId: toInteger(row.journey_id)})
MERGE (u)-[:WROTE]->(r)-[:ABOUT]->(j);

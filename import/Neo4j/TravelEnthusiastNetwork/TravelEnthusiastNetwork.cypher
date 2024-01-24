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
REQUIRE u.firstName IS NOT NULL;

CREATE CONSTRAINT User_lastname_exists IF NOT EXISTS
FOR (u:User)
REQUIRE u.lastName IS NOT NULL;

CREATE CONSTRAINT Destination_name_exists IF NOT EXISTS
FOR (d:Destination)
REQUIRE d.destinationName IS NOT NULL;

// load vertices
LOAD CSV WITH HEADERS
FROM 'file:///users.csv' AS row
MERGE (u:User {userId: toInteger(row.userId)})
SET 
u.firstName = row.firstName, 
u.lastName = row.lastName;

LOAD CSV WITH HEADERS
FROM 'file:///journeys.csv' AS row
MERGE (j:Journey {journeyId: toInteger(row.journeyId)})
SET 
j.journeyName = row.journeyName,
j.journeyStart = date(row.journeyStart),
j.journeyEnd = date(row.journeyEnd);

LOAD CSV WITH HEADERS
FROM 'file:///destinations.csv' AS row
MERGE (d:Destination {destinationId: toInteger(row.destinationId)}) 
SET
d.destinationName = row.destinationName;

LOAD CSV WITH HEADERS
FROM 'file:///countries.csv' AS row
MERGE (c:Country{countryCode: row.countryCode})
SET
c.countryName = row.countryName;

LOAD CSV WITH HEADERS
FROM 'file:///activities.csv' AS row
MERGE (:TravelActivity {activityName: row.activityName});

LOAD CSV WITH HEADERS
FROM 'file:///ratings.csv' AS row
MERGE (r:Rating {ratingId: toInteger(row.ratingId)})
SET
r.body = row.body,
r.rating = toInteger(row.rating);

//load edges
LOAD CSV WITH HEADERS
FROM 'file:///follows.csv' AS row
MATCH (u1:User {userId: toInteger(row.user1Id)})
MATCH (u2:User {userId: toInteger(row.user2Id)})
MERGE (u1)-[:FOLLOWS]->(u2);

LOAD CSV WITH HEADERS
FROM 'file:///is_within.csv' AS row
MATCH (d:Destination {destinationId: toInteger(row.destinationId)})
MATCH (c:Country {countryCode: row.countryCode})
MERGE (d)-[:IS_WITHIN]->(c);

LOAD CSV WITH HEADERS
FROM 'file:///led_to.csv' AS row
MATCH (j:Journey {journeyId: toInteger(row.journeyId)})
MATCH (d:Destination {destinationId: toInteger(row.destinationId)})
MERGE (j)-[e:LED_TO]->(d)
SET
e.startDate = date(row.startDate),
e.endDate = date(row.endDate);

LOAD CSV WITH HEADERS
FROM 'file:///likes.csv' AS row
MATCH (u:User {userId: toInteger(row.userId)})
MATCH (a:TravelActivity {activityName: row.activityName})
MERGE (u)-[:LIKES]->(a);

LOAD CSV WITH HEADERS
FROM 'file:///lives_in.csv' AS row
MATCH (u:User {userId: toInteger(row.userId)})
MATCH (d:Destination {destinationId: toInteger(row.destinationId)})
MERGE (u)-[:LIVES_IN]->(c);

LOAD CSV WITH HEADERS
FROM 'file:///offers.csv' AS row
MATCH (d:Destination {destinationId: toInteger(row.destinationId)})
MATCH (a:TravelActivity {activityName: row.activityName})
MERGE (d)-[:OFFERS]->(a);

LOAD CSV WITH HEADERS
FROM 'file:///participated.csv' AS row
MATCH (u:User {userId: toInteger(row.userId)})
MATCH (j:Journey {journeyId: toInteger(row.journeyId)})
MERGE (u)-[:PARTICIPATED]->(j);

LOAD CSV WITH HEADERS
FROM 'file:///wrote_about.csv' AS row
MATCH (u:User {userId: toInteger(row.userId)})
MATCH (r:Rating {ratingId: toInteger(row.ratingId)})
MATCH (j:Journey {journeyId: toInteger(row.journeyId)})
MERGE (u)-[:WROTE]->(r)-[:ABOUT]->(j);

// clear all data
MATCH (n)
DETACH DELETE n;

// load vertices
LOAD CSV WITH HEADERS FROM 'file:///csv/TravelEnthusiastNetwork/users.csv' AS row
CREATE (:User 
        {user_id: toInteger(row.user_id), 
        firstname: row.firstname, 
        lastname: row.lastname});

LOAD CSV WITH HEADERS FROM 'file:///csv/TravelEnthusiastNetwork/journeys.csv' AS row
CREATE (:Journey 
        {journey_id: toInteger(row.journey_id), 
        journey_name: row.journey_name,
        journey_start: date(row.journey_start),
        journey_end: date(row.journey_end)});

LOAD CSV WITH HEADERS FROM 'file:///csv/TravelEnthusiastNetwork/destinations.csv' AS row
CREATE (:Destination
        {destination_id: toInteger(row.destination_id), 
        destination_name: row.destination_name});

LOAD CSV WITH HEADERS FROM 'file:///csv/TravelEnthusiastNetwork/countries.csv' AS row
CREATE (:Country
        {country_code: row.country_code,
        country_name: row.country_name});

LOAD CSV WITH HEADERS FROM 'file:///csv/TravelEnthusiastNetwork/activities.csv' AS row
CREATE (:TravelActivity
        {activity_id: toInteger(row.activity_id),
        activity_name: row.activity_name});

LOAD CSV WITH HEADERS FROM 'file:///csv/TravelEnthusiastNetwork/ratings.csv' AS row
CREATE (:Rating
        {rating_id: toInteger(row.rating_id),
        body: row.body,
        rating: toInteger(row.rating)});

//load edges
LOAD CSV WITH HEADERS FROM 'file:///follows.csv' AS row
MATCH (u1:User {user_id: toInteger(row.user_id)})
MATCH (u2:User {user_id: toInteger(row.user_id)})
MERGE (u1)-[:FOLLOWS]->(u2);

LOAD CSV WITH HEADERS FROM 'file:///is_within.csv' AS row
MATCH (d:Destination {destination_id: row.destination_id})
MATCH (c:Country {country_code: row.country_code})
MERGE (d)-[:IS_WITHIN]->(c);

LOAD CSV WITH HEADERS FROM 'file:///led_to.csv' AS row
MATCH (j:Journey {journey_id: toInteger(row.journey_id)})
MATCH (d:Destination {destination_id: row.destination_id})
MERGE (j)-[:LED_TO
            {start_date: date(row.start_date),
            end_date: date(row.end_date)}
        ]->(d);

LOAD CSV WITH HEADERS FROM 'file:///likes.csv' AS row
MATCH (u:User {user_id: toInteger(row.user_id)})
MATCH (a:TravelActivity {activity_id: toInteger(row.activity_id)})
MERGE (u)-[:LIKES]->(a);

LOAD CSV WITH HEADERS FROM 'file:///lives_in.csv' AS row
MATCH (u:User {user_id: toInteger(row.user_id)})
MATCH (c:Country {country_code: row.country_code})
MERGE (u)-[:LIVES_IN]->(c);

LOAD CSV WITH HEADERS FROM 'file:///offers.csv' AS row
MATCH (d:Destination {destination_id: row.destination_id})
MATCH (a:TravelActivity {activity_id: toInteger(row.activity_id)})
MERGE (d)-[:OFFERS]->(a);

LOAD CSV WITH HEADERS FROM 'file:///participated.csv' AS row
MATCH (u:User {user_id: toInteger(row.user_id)})
MATCH (j:Journey {journey_id: toInteger(row.journey_id)})
MERGE (u)-[:PARTICIPATED]->(j);

LOAD CSV WITH HEADERS FROM 'file:///wrote_about.csv' AS row
MATCH (u:User {user_id: toInteger(row.user_id)})
MATCH (r:Rating {rating_id: toInteger(row.rating_id)})
MATCH (j:Journey {journey_id: toInteger(row.journey_id)})
MERGE (u)-[:WROTE]->(r)-[:ABOUT]->(j);

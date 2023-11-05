// destinations recommendation

//get destinations which offers activities in list
WITH ["Sightseeing", "Water Sports"] AS activity_list
MATCH (a:TravelActivity) WHERE a.activityName IN activity_list
WITH collect(a) AS activities
MATCH (d:Destination)
WHERE ALL(x IN activities WHERE (d)-[:OFFERS]->(x))
RETURN d.destinationName;

//offers 3 destinations that the user hasnt visited
WITH ["Sightseeing", "Water Sports"] AS activity_list
MATCH (a:TravelActivity) WHERE a.activityName IN activity_list
WITH collect(a) AS activities
MATCH (d:Destination)
WHERE (ALL(a IN activities WHERE (d)-[:OFFERS]->(a))
        AND NOT (:User {userId: 5})-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d))
OPTIONAL MATCH (d)<-[:LED_TO]-()<-[:ABOUT]-(r:Rating)
WITH d, coalesce(avg(r.rating), 0) as rate
RETURN d.destinationName AS name, rate
ORDER BY rate DESC
LIMIT 3;

//3 destinations offering activities, that user likes
MATCH (u:User {userId:5})-[:LIKES]->(a:TravelActivity)<-[:OFFERS]-(d:Destination)
WHERE NOT (u)-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d)
RETURN d, COUNT(a) AS count
ORDER BY count DESC
LIMIT 3;

//User Neighborhood

//first neighborhood
WITH 10 AS x_id
MATCH (u:User {userId:x_id})-[:FOLLOWS]->(u2) RETURN u,u2;

//second neighborhood
WITH 10 AS x_id
MATCH (u:User {userId:x_id})-[:FOLLOWS*2]->(u2)-[:FOLLOWS]->(u3) RETURN u,u3;

//second neighborhood without first neighborhood
WITH 10 AS x_id
MATCH (u:User {userId:x_id})-[:FOLLOWS]->(u2)-[:FOLLOWS]->(u3) WHERE NOT exists((u)-[:FOLLOWS]->(u3)) RETURN u,u3;


// User's visited destinations

WITH 55 AS user_id
MATCH (u:User {userId:user_id})-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d:Destination)
RETURN d.destinationName, COUNT(d) AS count
ORDER BY count DESC;


//user's travel buddies

WITH 50 AS user_id
MATCH (u:User {userId:user_id})-[:PARTICIPATED]->(:Journey)<-[:PARTICIPATED]-(travel_buddies:User)
WHERE NOT travel_buddies IS u
RETURN travel_buddies, COUNT(travel_buddies) AS count
ORDER BY count DESC;


//The most favourite month to visit destination

MATCH (d:Destination {destinationName: "Paris"})<-[:LED_TO]-(j:Journey)<-[:ABOUT]-(r:Rating)
WITH d, j.journeyStart.month AS month, coalesce(avg(r.rating), 0) as rate
ORDER BY rate DESC
LIMIT 1
RETURN month, rate;
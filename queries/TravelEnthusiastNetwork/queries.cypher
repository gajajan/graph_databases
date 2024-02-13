//USERS'S NEIGHBORHOOD

//first neighborhood
WITH 6 AS x_id
MATCH (:User {userId:x_id})-[:FOLLOWS]->(f)
RETURN f.userId, f.firstName, f.lastName;

//second neighborhood
WITH 6 AS x_id
MATCH (u:User {userId:x_id})-[:FOLLOWS*2]->(fof)
RETURN DISTINCT fof.userId, fof.firstName, fof.lastName;

//second neighborhood without first neighborhood
WITH 6 AS x_id
MATCH (u:User {userId:x_id})-[:FOLLOWS*2]->(fof)
WHERE NOT exists((u)-[:FOLLOWS]->(fof))  AND fof <> u
RETURN DISTINCT fof;


// DESTINATION RECOMMENDATION

//returns destinations which offers activities in list
WITH ["Sightseeing", "Water Sports"] AS activity_list
MATCH (a:TravelActivity) WHERE a.activityName IN activity_list
WITH collect(a) AS activities
MATCH (d:Destination)
WHERE ALL(x IN activities WHERE (d)-[:OFFERS]->(x))
RETURN d.destinationName;

//offers 3 destinations that the user hasnt visited
//destinations has to offer all activities in list
//returns destination's properties and
// rating of this destination
//order by rating average
WITH ["Book Festivals", "Fitness Bootcamps", "Craft Beer Tasting"] AS activity_list
MATCH (a:TravelActivity) WHERE a.activityName IN activity_list
WITH collect(a) AS activities
MATCH (d:Destination)
WHERE ALL(a IN activities WHERE (d)-[:OFFERS]->(a))
AND NOT exists ( (:User {userId: 151})-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d) )
OPTIONAL MATCH (d)<-[:LED_TO]-()<-[:ABOUT]-(r:Rating)
WITH d, coalesce(avg(r.rating), "Not rated.") as rate
RETURN d.destinationName AS name, rate
ORDER BY rate DESC;

//3 unvisited destinations offering activities, that user likes
MATCH (u:User {userId:299})-[:LIKES]->(a:TravelActivity)<-[:OFFERS]-(d:Destination)
WHERE NOT (u)-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d)
RETURN d.destinationName AS destination, COUNT(a) AS count, COLLECT(a.activityName) AS activities
ORDER BY count DESC;


//USER'S VISITED DESTINATIONS

//returns a destination and
// a number indicating how many times user visited specific destination

WITH 6 AS user_id
MATCH (u:User {userId:user_id})-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d:Destination)
RETURN d.destinationName, COUNT(d) AS count
ORDER BY count DESC, d.destinationName ASC;


//USER'S TRAVEL BUDDIES

//returns users
WITH 3 AS user_id
MATCH (u:User {userId:user_id})-[:PARTICIPATED]->(:Journey)<-[:PARTICIPATED]-(f:User)
WHERE NOT f IS u
RETURN DISTINCT f.userId AS userId, f.firstName AS firstName, f.lastName AS lastName, COUNT (f) AS count
ORDER BY firstName, lastName


//THE MOST FAVOURITE MONTH FOR VISITING SPECIFIC DESTINATION

//returns number indicating month in year
MATCH (d:Destination {destinationId: 1})<-[:LED_TO]-(j:Journey)<-[:ABOUT]-(r:Rating)
WITH d, j.journeyStart.month AS month, coalesce(avg(r.rating), 'Not rated.') as rate
ORDER BY rate DESC
LIMIT 1
RETURN month, rate;


//TRIP ANNIVERSARY

//this returns ids of users who has trip anniversary
MATCH (u:User)-[:PARTICIPATED]->(:Journey)-[e:LED_TO]->()
WHERE e.startDate.month <= date().month <= e.endDate.month
AND e.startDate.day <= date().day <= e.endDate.day
RETURN DISTINCT u.userId

//returns the destination and
// a number indicating how many years have passed since the trip
WITH 110 AS user_id
MATCH (u:User {userId:user_id})-[:PARTICIPATED]->(j:Journey)-[e:LED_TO]->(d:Destination)
WHERE e.startDate.month <= date().month <= e.endDate.month
AND e.startDate.day <= date().day <= e.endDate.day
RETURN d.destinationName AS destination, 
date().year - e.startDate.year AS years, 
e.startDate AS startDate, 
e.endDate AS endDate, 
j.journeyName AS journey;
//USERS'S NEIGHBORHOOD

:params 
{
    "user": 10,
    "activity_list": ["Sightseeing", "Water Sports"],
    "destId": 56
}

//first neighborhood
MATCH (:User {userId:$user})-[:FOLLOWS]->(f)
RETURN f.userId, f.firstName, f.lastName;

//second neighborhood
MATCH (u:User {userId:$user})-[:FOLLOWS*2]->(fof)
RETURN DISTINCT fof.userId, fof.firstName, fof.lastName;

//second neighborhood without first neighborhood
MATCH (u:User {userId:$user})-[:FOLLOWS*2]->(fof)
WHERE NOT exists((u)-[:FOLLOWS]->(fof))  AND fof <> u
RETURN DISTINCT fof;


// DESTINATION RECOMMENDATION

//returns destinations which offers activities in list

MATCH (a:TravelActivity) WHERE a.activityName IN $activity_list
WITH collect(a) AS activities
MATCH (d:Destination)
WHERE ALL(x IN activities WHERE (d)-[:OFFERS]->(x))
RETURN d.destinationName;

//offers 3 destinations that the user hasnt visited
//destinations has to offer all activities in list
//returns destination's properties and
// rating of this destination
//order by rating average

MATCH (a:TravelActivity) WHERE a.activityName IN $activity_list
WITH collect(a) AS activities
MATCH (d:Destination)
WHERE ALL(a IN activities WHERE (d)-[:OFFERS]->(a))
AND NOT exists ( (:User {userId: $user})-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d) )
OPTIONAL MATCH (d)<-[:LED_TO]-()<-[:ABOUT]-(r:Rating)
WITH d, coalesce(avg(r.rating), "Not rated.") as rate
RETURN d.destinationName AS name, rate
ORDER BY rate DESC;

//3 unvisited destinations offering activities, that user likes
MATCH (u:User {userId: $user})-[:LIKES]->(a:TravelActivity)<-[:OFFERS]-(d:Destination)
WHERE NOT (u)-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d)
OPTIONAL MATCH (d)<-[:LED_TO]-()<-[:ABOUT]-(r:Rating)
WITH d, coalesce(avg(r.rating), "Not rated.") as rate
RETURN d.destinationName AS name, rate
ORDER BY rate DESC
LIMIT 3;

//USER'S VISITED DESTINATIONS

//returns a destination and
// a number indicating how many times user visited specific destination

MATCH (u:User {userId:$user})-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d:Destination)
RETURN d.destinationName, COUNT(d) AS count
ORDER BY count DESC, d.destinationName ASC;


//USER'S TRAVEL BUDDIES

//returns users
MATCH (u:User {userId:$user})-[:PARTICIPATED]->(:Journey)<-[:PARTICIPATED]-(f:User)
WHERE NOT f IS u
RETURN DISTINCT f.userId AS userId, f.firstName AS firstName, f.lastName AS lastName, COUNT (f) AS count
ORDER BY firstName, lastName


//THE MOST FAVOURITE MONTH FOR VISITING SPECIFIC DESTINATION

//returns number indicating month in year
MATCH (d:Destination {destinationId: $destId})<-[:LED_TO]-(j:Journey)<-[:ABOUT]-(r:Rating)
WITH d, j.journeyStart.month AS month, coalesce(avg(r.rating), 'Not rated.') as rate
ORDER BY rate DESC
LIMIT 1
RETURN month, rate;

//TEXT SEARCH

MATCH (u:User)
WHERE toUpper(u.firstName) CONTAINS toUpper($substr)
OR toUpper(u.lastName) CONTAINS toUpper($substr)
RETURN u
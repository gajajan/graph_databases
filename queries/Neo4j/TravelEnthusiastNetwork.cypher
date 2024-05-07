//DOTAZY ODDELENY POMOCI NAZVU S VELKYMI PISMENY


//PARAMS SETTING
:params 
{
    "user": 10,
    "activity_list": ["Sightseeing", "Water Sports"],
    "destId": 7,
    "substr": "RoB"
}


//FIRST NEIGHBORHOOD
MATCH (:User {userId:$user})-[:FOLLOWS]->(f)
RETURN f.userId, f.firstName, f.lastName;


//SECOND NEIGHBORHOOD
MATCH (u:User {userId:$user})-[:FOLLOWS*2]->(fof)
RETURN DISTINCT fof.userId, fof.firstName, fof.lastName;


//SECOND NEIGHBORHOOD WITHOUT FIRST
MATCH (u:User {userId:$user})-[:FOLLOWS*2]->(fof)
WHERE NOT exists((u)-[:FOLLOWS]->(fof))  AND fof <> u
RETURN DISTINCT fof;


//VISITED DESTINATIONS
//vrací jméno destinace
// a počet indikující kolikrát uživatel danou destinaci navstivil
MATCH (u:User {userId:$user})-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d:Destination)
RETURN d.destinationName, COUNT(d) AS count
ORDER BY count DESC, d.destinationName ASC;


//CO-TRAVELERS
MATCH (u:User {userId:$user})-[:PARTICIPATED]->(:Journey)<-[:PARTICIPATED]-(f:User)
WHERE NOT f IS u
RETURN DISTINCT f.userId AS userId, f.firstName AS firstName, f.lastName AS lastName, COUNT (f) AS count
ORDER BY firstName, lastName


//DESTINATIONS OFFERING ALL ACTIVITIES IN LIST
MATCH (a:TravelActivity) WHERE a.activityName IN $activity_list
WITH collect(a) AS activities
MATCH (d:Destination)
WHERE ALL(x IN activities WHERE (d)-[:OFFERS]->(x))
RETURN d;


//DESTINATION RECOMMENDATION BASED ON ACTIVITY LIST
//nabízí 3 destinace které uživatel nenavštívil
//tato destinace musí nabízet všechny aktivity formulované v activityList
//dotaz vrací jméno destinace a její hodnocení, seřazené podle hodnocení
MATCH (a:TravelActivity) WHERE a.activityName IN $activity_list
WITH collect(a) AS activities
MATCH (d:Destination)
WHERE ALL(a IN activities WHERE (d)-[:OFFERS]->(a))
AND NOT exists ( (:User {userId: $user})-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d) )
OPTIONAL MATCH (d)<-[:LED_TO]-()<-[:ABOUT]-(r:Rating)
WITH d, coalesce(avg(r.rating), "Not rated.") as rating
RETURN d.destinationName AS name, rating
ORDER BY rating DESC
LIMIT 3;


//DESTINATIONS OFFERING ACTIVITIES THAT USER LIKES
// vrací destinaci a
// cislo indikujici kolik aktivit ma destinace s uzivatelem spolecne
MATCH (:User {userId: $user})-[:LIKES]->(a:TravelActivity)<-[:OFFERS]-(d:Destination)
RETURN d.destinationName AS name, COUNT(a) AS count
ORDER BY count DESC, name;


//DESTINATION RECOMMENDATION BASED ON USER'S FAVOURITE ACTIVITIES
MATCH (u:User {userId: $user})-[:LIKES]->(a:TravelActivity)<-[:OFFERS]-(d:Destination)
WHERE NOT (u)-[:PARTICIPATED]->(:Journey)-[:LED_TO]->(d)
OPTIONAL MATCH (d)<-[:LED_TO]-()<-[:ABOUT]-(r:Rating)
WITH d, coalesce(avg(r.rating), "Not rated.") as rate
RETURN d.destinationName AS name, rate
ORDER BY rate DESC
LIMIT 3;


//THE MOST FAVOURITE MONTH FOR VISITING SPECIFIC DESTINATION
//vrací cislo reprezentujici mesic v roce a hodnoceni
//vysledek je serazen podle hodnoceni a omezen na 3
MATCH (d:Destination {destinationId: $destId})<-[l:LED_TO]-(j:Journey)
OPTIONAL MATCH (j)<-[:ABOUT]-(r:Rating)
RETURN l.startDate.month AS month, 
coalesce(avg(r.rating), "not rated") as rating
ORDER BY rating DESC
LIMIT 3;


//TEXT SEARCH
//vraci uzivatele jejichz jmeno obsahuje vstupni retezec
MATCH (u:User)
WHERE toUpper(u.firstName) CONTAINS toUpper($substr)
OR toUpper(u.lastName) CONTAINS toUpper($substr)
RETURN u.userId as userId, u.firstName + " " + u.lastName as name
ORDER BY u.firstName, u.lastName
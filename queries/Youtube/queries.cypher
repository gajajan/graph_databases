//Q1-Q4
//depth x is specified by [FRIENDS*1..x]
MATCH (u:User {userId: 1})-[:FRIENDS*1..2]-(f)
WHERE u <> f
RETURN COUNT(DISTINCT(f))

//Q5
MATCH p=shortestPath((:User {userId:12000})-[:FRIENDS*]-(:User {userId:1047}))
RETURN p

//Q6
MATCH p=shortestPath((:User {userId:12000})-[:FRIENDS*]->(:User {userId:1047}))
RETURN p

//Q7
MATCH (u:User)
WHERE u.firstName STARTS WITH "Ma" AND u.age>75
RETURN COUNT(u)

//Q8
MATCH (u:User)
WHERE u.firstName = "James"
RETURN AVG(u.age)
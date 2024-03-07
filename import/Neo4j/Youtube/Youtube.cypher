MATCH (n)
DETACH DELETE n;

CREATE CONSTRAINT User_id_nodekey IF NOT EXISTS
FOR (u:User)
REQUIRE u.userId IS NODE KEY;

// load vertices
:auto LOAD CSV WITH HEADERS
FROM 'file:///users.csv' AS row
CALL {
    WITH row
    CREATE (u:User {userId: toInteger(row.userId)})
} IN TRANSACTIONS;

//load edges
:auto LOAD CSV WITH HEADERS
FROM 'file:///com-youtube.ungraph.tsv' AS row
FIELDTERMINATOR '\t'
CALL {
    WITH row
    MATCH (u1:User {userId: toInteger(row.FromNodeId)})
    MATCH (u2:User {userId: toInteger(row.ToNodeId)})
    MERGE (u1)-[:FRIENDS]->(u2)
} IN TRANSACTIONS;

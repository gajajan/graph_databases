// clear all data
MATCH (n)
DETACH DELETE n;

CREATE CONSTRAINT Product_id_nodekey IF NOT EXISTS
FOR (p:Product)
REQUIRE p.productId IS NODE KEY;

CREATE CONSTRAINT Brand_id_nodekey IF NOT EXISTS
FOR (b:Brand)
REQUIRE b.brandName IS NODE KEY;

CREATE CONSTRAINT Gender_id_nodekey IF NOT EXISTS
FOR (g:Gender)
REQUIRE g.genderName IS NODE KEY;

// load vertices
:auto LOAD CSV WITH HEADERS
FROM 'file:///myntra_products_catalog.csv' AS row
CALL {
    WITH row
    MERGE (g:Gender {genderName: row.gender})
    MERGE (b:Brand {brandName: row.productBrand})
    MERGE (p:Product {productId: toInteger(row.productId)})
    SET 
    p.productName = row.productName, 
    p.price = row.price
    MERGE (p)-[:MANUFACTURED_BY]->(b)
    MERGE (p)-[:DEDICATED_TO]->(g)
} IN TRANSACTIONS OF 500 ROWS;

//load edges
:auto LOAD CSV WITH HEADERS
FROM 'file:///bought_with.csv' AS row
CALL {
    WITH row
    MATCH (source:Product {productId: toInteger(row.productId)})
    MATCH (dest:Product {productId: toInteger(row.productId)})
    MERGE (source)-[e:BOUGHT_WITH]->(dest)
    SET e.weight = toFloat(row.weight)
} IN TRANSACTIONS OF 500 ROWS;

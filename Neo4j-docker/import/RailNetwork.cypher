// clear all data
MATCH (n)
DETACH DELETE n;

CREATE CONSTRAINT Station_id_nodekey IF NOT EXISTS
FOR (s:Station)
REQUIRE s.stationId IS NODE KEY;

// load vertices
LOAD CSV WITH HEADERS 
FROM 'file:///RailNetwork/stations.csv' AS row
MERGE (s:Station {stationId: toInteger(row.stationId)})
SET 
s.stationName = row.stationName,
s.latitude =  toFloat(row.latitude),
s.longitude = toFloat(row.longitude);

//load edges
LOAD CSV WITH HEADERS
FROM 'file:///RailNetwork/leads_to.csv' AS row
MATCH (source:Station {stationId: toInteger(row.sourceId)})
MATCH (dest:Station {stationId: toInteger(row.destId)})
MERGE (source)-[e:LEADS_TO]->(dest)
SET
    e.length = toFloat(row.length);
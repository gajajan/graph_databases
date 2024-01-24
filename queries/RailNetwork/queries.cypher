MATCH (src:Station {stationId: 1048}),
      (dst:Station {stationId: 319})
MATCH p = (src)-[:LEADS_TO]-+(dst)
RETURN reduce(acc = 0, r in relationships(p) | acc + r.length)
  AS distance
ORDER BY distance LIMIT 1

//shortest path - the smallest vertices count
MATCH (source:Station {stationId: 1048}), (dest:Station {stationId: 319})
MATCH path = shortestPath((source)-[:LEADS_TO*]-(dest))
RETURN nodes(path) AS stations, length(path) AS pathLength;

//shortest path by property length
//computationally expensive - it tries every path of length 1 - 8 and takes minimum of them
//the shortest path has 11 edges
//there is no need to check cycles in path -> it takes minimum distance
MATCH (source:Station {stationId: 1048}), (dest:Station {stationId: 1066})
MATCH path = (source)-[:LEADS_TO*1..8]-(dest)
WITH path,
reduce(l=0, r in relationships(path) | l+r.length) AS length
ORDER BY length ASC
LIMIT 1
RETURN [node IN nodes(path) | node.stationName] AS stations, length(path) AS pathLength, length;


//gds library
CALL gds.graph.project(
    'stations',
    'Station',
    'LEADS_TO',
    {
        relationshipProperties: 'length'
    }
);

//a* graph projection
CALL gds.graph.project(
    'a*',
    'Station',
    'LEADS_TO',
    {
        nodeProperties: ['latitude', 'longitude'],
        relationshipProperties: 'length'
    }
)

//PATHS

//dijkstra algorithm

MATCH (source:Station {stationId: 1048}), (target:Station {stationId: 319})
CALL gds.shortestPath.dijkstra.stream('stations', {
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: 'length'
})
YIELD totalCost, nodeIds
RETURN  [nodeId IN nodeIds | gds.util.asNode(nodeId).stationName] AS stations, totalCost

//random walk
MATCH (src:Station )
WHERE src.stationId < 10
WITH COLLECT(src) as sourceNodes
CALL gds.randomWalk.stream(
  'stations',
  {
    sourceNodes: sourceNodes,
    walkLength: 8,
    walksPerNode: 1,
    inOutFactor: 0.2
  }
)
YIELD path
RETURN [node IN nodes(path) | [node.stationName, node.stationId] ] AS stations

//a*
MATCH (source:Station {stationId: 1048}), (target:Station {stationId: 319})
CALL gds.shortestPath.astar.stream('a*',{
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: "length",
    latitudeProperty: "latitude",
    longitudeProperty: "longitude"
})
YIELD nodeIds, totalCost
RETURN  [nodeId IN nodeIds | gds.util.asNode(nodeId).stationName] AS stations, totalCost

//CENTRALITY ALGORITHMS

//pageRank

CALL gds.pageRank.stream('stations')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).stationName AS name, score
ORDER BY score DESC, name ASC
LIMIT 10;

//degree centrality

CALL gds.degree.stream('stations')
YIELD nodeId, score
WHERE score>8
RETURN gds.util.asNode(nodeId).stationName AS name, score AS neighboors
ORDER BY neighboors DESC, name DESC

//betweenness centrality

CALL gds.betweenness.stream('stations')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).stationName AS name, score
ORDER BY score DESC
LIMIT 10;

//eigenvector centrality

CALL gds.eigenvector.stream('stations')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).stationName AS name, score
ORDER BY score DESC, name ASC
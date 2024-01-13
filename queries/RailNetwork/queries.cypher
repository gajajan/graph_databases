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

//SHORTEST PATH

//yens algorithm
MATCH (source:Station {stationId:1048}), (target:Station {stationId: 319})
CALL gds.shortestPath.yens.stream('stations', {
    sourceNode: source,
    targetNode: target,
    k: 3,
    relationshipWeightProperty: 'length'
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
    index,
    gds.util.asNode(sourceNode).stationName AS sourceNodeName,
    gds.util.asNode(targetNode).stationName AS targetNodeName,
    totalCost,
    [nodeId IN nodeIds | gds.util.asNode(nodeId).stationName] AS nodeNames,
    costs,
    nodes(path) as path
ORDER BY index

//dijkstra algorithm

MATCH (source:Station {stationId: 1048}), (target:Station {stationId: 319})
CALL gds.shortestPath.dijkstra.stream('stations', {
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: 'length'
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
    index,
    gds.util.asNode(sourceNode).stationName AS sourceNodeName,
    gds.util.asNode(targetNode).stationName AS targetNodeName,
    totalCost,
    [nodeId IN nodeIds | gds.util.asNode(nodeId).stationName] AS nodeNames,
    costs,
    nodes(path) as path,
    length(path) as pathLength
ORDER BY index
LIMIT 1;

//CENTRALITY ALGORITHMS

//well-known pageRank

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
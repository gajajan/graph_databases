//QUERIES SEPARATED BY NAMES WITH CAPITAL LETTERS


//PARAMS SETTING
:params 
{
    "src": 1048,
    "dst": 319
}


//UNWEIGHTED SHORTEST PATH
MATCH (source:Station {stationId: $src}), (dest:Station {stationId: $dst})
MATCH path = shortestPath((source)-[:LEADS_TO*]-(dest))
RETURN nodes(path) AS stations, length(path) AS pathLength;


//WEIGHTED SHORTEST PATH
//not working! - very computationally expensive
MATCH (src:Station {stationId: $src}),
      (dst:Station {stationId: $dst})
MATCH p = (src)-[:LEADS_TO]-+(dst)
RETURN reduce(acc = 0, r in relationships(p) | acc + r.length)
  AS distance
ORDER BY distance ASC
LIMIT 1


//WEIGHTED SHORTEST PATH
//the shortest path of all paths having 1 - 8 edges
//computationally expensive - it tries every path of length 1 - 8 and takes minimum of them
//there is no need to check cycles in path
MATCH (source:Station {stationId: $src}), (dest:Station {stationId: $dst})
MATCH path = (source)-[:LEADS_TO*1..8]-(dest)
WITH path,
reduce(l=0, r in relationships(path) | l+r.length) AS distance
ORDER BY distance ASC
LIMIT 1
RETURN [node IN nodes(path) | node.stationName] AS stations, length(path) AS pathLength, length;


//GRAPH PROJECTION
CALL gds.graph.project(
    'stations',
    'Station',
    'LEADS_TO',
    {
        nodeProperties: ['latitude', 'longitude'],
        relationshipProperties: 'length'
    }
)


//DIJKSTRA'S ALGORITHM
MATCH (source:Station {stationId: $src}), (target:Station {stationId: $dst})
CALL gds.shortestPath.dijkstra.stream('stations', {
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: 'length'
})
YIELD totalCost, nodeIds
RETURN  [nodeId IN nodeIds | gds.util.asNode(nodeId).stationName] AS stations, totalCost


//A*
//uses latitude and longitude like heuristic
MATCH (source:Station {stationId: $src}), (target:Station {stationId: $dst})
CALL gds.shortestPath.astar.stream('a*',{
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: "length",
    latitudeProperty: "latitude",
    longitudeProperty: "longitude"
})
YIELD nodeIds, totalCost
RETURN  [nodeId IN nodeIds | gds.util.asNode(nodeId).stationName] AS stations, totalCost


//RANDOM WALK
//from vertex with id 9 with point distance
MATCH (src:Station {stationId: 9})
WITH src
CALL gds.randomWalk.stream(
  'stations',
  {
    sourceNodes: src,
    walkLength: 8,
    walksPerNode: 3,
    inOutFactor: 0.2,
    returnFactor: 20
  }
)
YIELD path
WITH path, src, nodes(path)[-1] AS dst
RETURN [node IN nodes(path) | node.stationId ] AS stations,
point.distance(
    point({longitude: src.longitude, latitude: src.latitude}),
    point({longitude: dst.longitude, latitude: dst.latitude})
)
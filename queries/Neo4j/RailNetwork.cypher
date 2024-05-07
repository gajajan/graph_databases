//DOTAZY ODDELENY POMOCI NAZVU S VELKYMI PISMENY


//PARAMS SETTING
:params 
{
    "src": 1048,
    "dst": 319
}


//UNWEIGHTED SHORTEST PATH
MATCH (source:Station {stationId: $src}), (dest:Station {stationId: $dst})
MATCH path = shortestPath((source)-[:LEADS_TO*]-(dest))
RETURN nodes(path) AS stations, length(path) AS edgeCount;


//WEIGHTED SHORTEST PATH
//nelze - vypocetne narocne
MATCH (src:Station {stationId: $src}),
      (dst:Station {stationId: $dst})
MATCH p = (src)-[:LEADS_TO]-+(dst)
RETURN reduce(s = 0, r in relationships(p) | s + r.length)
  AS distance
ORDER BY distance ASC
LIMIT 1


//WEIGHTED SHORTEST PATH
//nejkratsi cesty ktere maji 1 - 8 hran
//vypocetne narocnejsi
MATCH (source:Station {stationId: $src}), (dest:Station {stationId: $dst})
MATCH path = (source)-[:LEADS_TO*1..8]-(dest)
WITH path,reduce(l=0, r in relationships(path) | l+r.length) AS distance
ORDER BY distance ASC
LIMIT 1
RETURN [node IN nodes(path) | node.stationName] AS stations, length(path) AS edgeCount, distance;


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
//pouziva zemepisnou sirku a delku jako heuristiku
MATCH (source:Station {stationId: $src}), (target:Station {stationId: $dst})
CALL gds.shortestPath.astar.stream('stations',{
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: "length",
    latitudeProperty: "latitude",
    longitudeProperty: "longitude"
})
YIELD nodeIds, totalCost
RETURN  [nodeId IN nodeIds | gds.util.asNode(nodeId).stationName] AS stations, totalCost


//RANDOM WALK
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
//DOTAZY ODDELENY POMOCI NAZVU S VELKYMI PISMENY

// CALL GDS.GRAPH.PROJECT
CALL gds.graph.project(
    'cities',
    'City',
    {
    CONNECTED: {
      properties: 'distance',
      orientation: 'UNDIRECTED'
    }
  }
);

// MINIMUM SPANNING TREE
MATCH (s:City {name: 'A'})
CALL gds.spanningTree.stream('cities', {
  sourceNode: s,
  relationshipWeightProperty: 'distance'
})
YIELD nodeId,parentId, weight
WITH gds.util.asNode(nodeId) AS fromNode, gds.util.asNode(parentId) AS toNode, weight
WHERE fromNode.name <> toNode.name
RETURN COLLECT({
  from: fromNode.name,
  to: toNode.name,
  distance: weight
}) AS edge,
sum(weight) AS weightSum;

// CENTRALITY

// DEGREE CENTRALITY
CALL gds.degree.stream('cities')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC, name ASC

// CLOSSENESS CENTRALITY
CALL gds.closeness.stream('cities')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC

// BETWEENESS CENTRALITY
CALL gds.betweenness.stream('cities')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC


// COMUNITY DETECTION

// TRIANGLE COUNT
CALL gds.triangleCount.stream('cities')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).name AS name, triangleCount
ORDER BY triangleCount DESC

// LOCAL CLUSTERING COEFFICIENT
CALL gds.localClusteringCoefficient.stream('cities')
YIELD nodeId, localClusteringCoefficient
RETURN gds.util.asNode(nodeId).name AS name, localClusteringCoefficient
ORDER BY localClusteringCoefficient DESC

// WEAK CONNECTED COMPONENTS
CALL gds.wcc.stream('cities')
YIELD nodeId, componentId
WITH componentId, gds.util.asNode(nodeId).name AS city
ORDER BY componentId, city
RETURN componentId, COLLECT(city) AS citiesInComunitty

// LOUVAIN
CALL gds.louvain.stream('cities')
YIELD nodeId, communityId
WITH communityId, gds.util.asNode(nodeId).name AS city
ORDER BY communityId, city
RETURN communityId, COLLECT(city) AS citiesInComunitty

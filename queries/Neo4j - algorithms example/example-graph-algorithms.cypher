// CREATE NODES REPRESENTING CITIES
CREATE (a:City {name: 'A'}),
       (b:City {name: 'B'}),
       (c:City {name: 'C'}),
       (d:City {name: 'D'}),
       (e:City {name: 'E'}),
       (f:City {name: 'F'}),
       (g:City {name: 'G'}),
       (a)-[:CONNECTED {distance: 50}]->(b),
       (c)-[:CONNECTED {distance: 75}]->(b),
       (a)-[:CONNECTED {distance: 82}]->(c),
       (d)-[:CONNECTED {distance: 95}]->(c),
       (e)-[:CONNECTED {distance: 36}]->(c),
       (a)-[:CONNECTED {distance: 120}]->(d),
       (b)-[:CONNECTED {distance: 90}]->(d),
       (e)-[:CONNECTED {distance: 85}]->(d),
       (e)-[:CONNECTED {distance: 45}]->(f),
       (f)-[:CONNECTED {distance: 63}]->(g),
       (g)-[:CONNECTED {distance: 12}]->(a);

// DELETE CITIES AND EDGES BETWEEN THEM
MATCH (city:City)-[edge:CONNECTED]->()
DELETE city, edge;

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
MATCH (n:City {name: 'A'})
CALL gds.spanningTree.stream('cities', {
  sourceNode: n,
  relationshipWeightProperty: 'distance'
})
YIELD nodeId,parentId, weight
WITH gds.util.asNode(nodeId) AS fromNode, gds.util.asNode(parentId) AS toNode, weight
WHERE fromNode.name <> toNode.name
RETURN COLLECT({
  from: fromNode.name,
  to: toNode.name,
  distance: weight
}) AS spanningTree,
sum(weight);

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

// EIGEN VECTOR
CALL gds.eigenvector.stream('cities')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC, name ASC

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
RETURN gds.util.asNode(nodeId).name AS name, componentId
ORDER BY componentId, name

// LOUVAIN
CALL gds.louvain.stream('cities')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).name AS name, communityId
ORDER BY componentId, name

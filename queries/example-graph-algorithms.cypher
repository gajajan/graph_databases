// Create nodes representing cities
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

// Delete cities and edges between them
MATCH (city:City)-[edge:CONNECTED]->()
DELETE city, edge;

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

//minimum spanning tree
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

//CENTRALITY

//degree centrality
CALL gds.degree.stream('cities')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC, name ASC

//closseness centrality
CALL gds.closeness.stream('cities')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC

//betweeness centrality
CALL gds.betweenness.stream('cities')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC

//eigen vector
CALL gds.eigenvector.stream('cities')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC, name ASC

//COMUNITY DETECTION

//triangle count
CALL gds.triangleCount.stream('cities')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).name AS name, triangleCount
ORDER BY triangleCount DESC

//local clustering coefficient
CALL gds.localClusteringCoefficient.stream('cities')
YIELD nodeId, localClusteringCoefficient
RETURN gds.util.asNode(nodeId).name AS name, localClusteringCoefficient
ORDER BY localClusteringCoefficient DESC

//weak connected components
CALL gds.wcc.stream('cities')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).name AS name, componentId
ORDER BY componentId, name

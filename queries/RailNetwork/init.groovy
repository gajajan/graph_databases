//parameters for connector
url = "embedded:/Users/gajaj/orientdb-tp3-3.2.23/databases/RailNetwork";
user = "root";
password = "root";

//OrientDb database connector
graph = OrientGraph.open(url, user, password);

//establishing a graph traversal source object
//for example we can retrieve graph vertices with g.V().valueMap()
g = graph.traversal();
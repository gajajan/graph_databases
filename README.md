# Graph Databases
Repository for a bachelor's thesis focusing on graph databases.

## Content
* The `*-docker` folders contain the necessary files for building Docker images.
* The `kidiplom` folder contains the current version of the text document.
* The `queries` folder includes queries for different datasets mentioned in the text document.
  - Files with Cypher queries
  - Files with Gremlin queries
  - Files with AQL queries
  - Files with OrientDB SQL queries
  - Files with queries for Neo4j algorithms
* The `Measurements.xlsx` file with the experiment results.

## Running Docker

### OrientDB
```bash
docker build -t orientdb-database:1.0 .
docker run -p 2480:2480 orientdb-database:1.0
```

OrientDB Studio is available at the IP address http://localhost:2480. Initial password and username are set to `root`. The databases __TravelEnthusiastNetwork__ and __RailNetwork__ are loaded automatically. For testing the import in OrientDB, use in the interactive shell
```bash
sh youtube-import-test.sh
sh youtube-properties-import.sh
```

The Gremlin Console is located in the `/orientdb/bin/` folder. You can connect to the database with the name _<SELECTED_DATABASE>_ using `/orientdb/bin/gremlin.sh` with the following commands:
```groovy
//OrientDb database connector
graph = OrientGraph.open("plocal:/orientdb/databases/<SELECTED_DATABASE>", "root", "root");

//establishing a graph traversal source object
g = graph.traversal();
```

Alternatively, you can use initialization files to connect to the database with the name _<SELECTED_DATABASE>_, which are located in the `/init-files-gremlin/` folder. The command for this in the interactive shell is:
```bash
/orientdb/bin/gremlin.sh -i /init-files-gremlin/<SELECTED_DATABASE>.groovy -Xmx4g
```
These files also contain functions with prepared queries, which are more convenient to use. List of these functions is printed by `help()` function. :warning: Every function has first parameter `g`. For __Youtube__ database functions return measured time and result.

The usage of lightweight edges must be defined before import in JSON files by specifying the `useLightweightEdges` parameter as `true`.

### Neo4j
```bash
docker build -t neo4j-database:1.0 .
docker run -p 7474:7474 -p 7687:7687 neo4j-database:1.0
```

The Neo4j Browser is available at the IP address http://localhost:7474. There is __no__ initial password and username because authentification in docker file is set to `none`.

Create a database with the name _<DATABASE_NAME>_ in the Neo4j Browser with the command:
```cypher
CREATE DATABASE <DATABASE_NAME>
```
You need four databases __travelenthusiastnetwork__, __railnetwork__, __youtube__ and one for testing algorithms.

Then you can select database with the name _<DATABASE_NAME>_ with the command:
```cypher
:use <DATABASE_NAME>
```

Import data into the selected database in the Neo4j Browser using the Cypher files located in the `/import/` folder. This method was also used to test the import in Neo4j.

In Cypher queries, parameters are used. Values _y1,...,yn_ of parameters _x1,...,xn_ can be specified with command:
```cypher
:params 
{
    "x1": y1,
    ...,
    "xn": yn
}
```

### ArangoDB
```bash
docker build -t arangodb-database:1.0 . 
docker run -p 8529:8529 arangodb-database:1.0
```

The ArangoDB Web Interface is available at the IP address http://localhost:8529. Initial password and username are set to `root`.

The databases __TravelEnthusiastNetwork__ and __RailNetwork__ can be imported via the interactive shell using
```bash
sh import.sh
```
For testing the import in ArangoDB, use in the interactive shell
```bash
sh youtube-import-test.sh
sh youtube-properties-import.sh
```

In AQL queries, bind parameters are used. More information about them can be found at https://docs.arangodb.com/3.12/aql/fundamentals/bind-parameters/.
# Graph Databases
Repository for a bachelor's thesis focusing on graph databases.

## Content
* The `*-docker` folders contain the necessary files for building Docker images.
* The `obhajoba` folder contains files for the presentation of the bachelor's thesis.
* The `kidiplom` folder contains the current version of the text document.
* The `queries` folder includes queries for different datasets mentioned in the text document.
  - Files with Cypher queries
  - Files with Gremlin queries
  - Files with AQL queries
  - Files with OrientDB SQL queries
  - Files with queries for Neo4j algorithms
* The `plot-result` folder contains Python files for plotting results.

## Running Docker

### OrientDB
```bash
docker build -t orientdb-database:1.0 .
docker run -p 2480:2480 orientdb-database:1.0
```

OrientDB Studio is available at the IP address http://localhost:2480. The databases __TravelEnthusiastNetwork__ and __RailNetwork__ are loaded automatically. For testing the import in OrientDB, use in the interactive shell
```bash
sh import-test.sh
```

The Gremlin Console is located in the `/orientdb/bin/` folder. You can use initialization files to connect to databases, which are located in the `/init-files-gremlin/` folder. The command for this in the interactive shell is in the form 
```bash
/orientdb/bin/gremlin.sh -i /init-files-gremlin/<SELECTED_DATABASE>.groovy
```

### Neo4j
```bash
docker build -t neo4j-database:1.0 .
docker run -p 7474:7474 -p 7687:7687 neo4j-database:1.0
```

The Neo4j Browser is available at the IP address http://localhost:7474. Create a database in the Neo4j Browser with the command 
```cypher
CREATE DATABASE <DATABASE_NAME>
```

Then select this database with the 

```cypher
:use <DATABASE_NAME>
```

Import data using the Cypher files located in the `/import/` folder. This method was also used for testing the import in Neo4j.

### ArangoDB
```bash
docker build -t arangodb-database:1.0 . 
docker run -p 8529:8529 arangodb-database:1.0
```

The ArangoDB Web Interface is available at the IP address http://localhost:8529. The databases __TravelEnthusiastNetwork__ and __RailNetwork__ can be imported via the interactive shell using
```bash
sh import.sh
```
For testing the import in ArangoDB, use in the interactive shell
```bash
sh import-test.sh
```

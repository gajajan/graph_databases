#! /bin/sh

START_TIME=$(date +%s)

echo "Youtube vertices import started."

/usr/bin/arangoimport --file "/csv/Youtube/users.csv" --type csv --server.database "Youtube" --create-database true --collection "User" --create-collection true --translate "userId=_key" --server.password "root" --on-duplicate "ignore"

END_TIME=$(date +%s)
VERTICES_IMPORT_TIME=$((END_TIME - START_TIME))

echo "Youtube vertices import ended."

echo
echo
echo

START_TIME=$(date +%s)

echo "Youtube edges import started."

/usr/bin/arangoimport --file "/csv/Youtube/com-youtube.ungraph.tsv" --type tsv --server.database "Youtube" --collection "FRIENDS"  --create-collection true --create-collection-type "edge" --from-collection-prefix "User" --to-collection-prefix "User" --translate "FromNodeId=_from" --translate "ToNodeId=_to" --server.password "root"

END_TIME=$(date +%s)
EDGES_IMPORT_TIME=$((END_TIME - START_TIME))

echo "Youtube edges import ended."

echo
echo
echo

echo "Youtube vertices: Total execution time: ${VERTICES_IMPORT_TIME} seconds."
echo "Youtube edges: Total execution time: ${EDGES_IMPORT_TIME} seconds."
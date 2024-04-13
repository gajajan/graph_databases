#! /bin/sh

START_TIME=$(date +%s)

echo "Youtube vertices import started."

/usr/bin/arangoimport --file "/csv/Youtube/users.csv" --type csv --server.database "Youtube" --create-database true --collection "User" --create-collection true --translate "userId=_key" --server.password "root" --on-duplicate "ignore"

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "Youtube vertices import ended. Total execution time: ${ELAPSED_TIME} seconds."

echo
echo
echo

START_TIME=$(date +%s)

echo "Youtube edges import started."

/usr/bin/arangoimport --file "/csv/Youtube/com-youtube.ungraph.tsv" --type tsv --server.database "Youtube" --collection "FRIENDS"  --create-collection true --create-collection-type "edge" --from-collection-prefix "User" --to-collection-prefix "User" --translate "FromNodeId=_from" --translate "ToNodeId=_to" --server.password "root"

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "Youtube edges import ended. Total execution time: ${ELAPSED_TIME} seconds."

echo
echo
echo

START_TIME=$(date +%s)

echo "Youtube properties import started."

/usr/bin/arangoimport --file "/csv/Youtube/properties.csv" --type csv --server.database "Youtube" --collection "User" --server.password "root" --on-duplicate "update" --translate "userId=_key"

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "Youtube properties import ended. Total execution time: ${ELAPSED_TIME} seconds."
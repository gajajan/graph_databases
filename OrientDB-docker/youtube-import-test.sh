#! /bin/sh

START_TIME=$(date +%s)

echo "Youtube vertices import started."

/orientdb/bin/oetl.sh /import/Youtube/users.json

END_TIME=$(date +%s)
VERTICES_IMPORT_TIME=$((END_TIME - START_TIME))

echo "Youtube vertices import ended."

echo
echo
echo

START_TIME=$(date +%s)

echo "Youtube edges import started."

/orientdb/bin/oetl.sh /import/Youtube/friends.json

END_TIME=$(date +%s)
EDGES_IMPORT_TIME=$((END_TIME - START_TIME))

echo "Youtube edges import ended."

echo
echo
echo

echo "Youtube vertices: Total execution time: ${VERTICES_IMPORT_TIME} seconds."
echo "Youtube edges: Total execution time: ${EDGES_IMPORT_TIME} seconds."
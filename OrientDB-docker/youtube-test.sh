#! /bin/sh

START_TIME=$(date +%s)

echo "Youtube vertices import started."

/orientdb/bin/oetl.sh /import/Youtube/users.json

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "Youtube vertices import ended. Total execution time: ${ELAPSED_TIME} seconds."

echo
echo
echo

START_TIME=$(date +%s)

echo "Youtube edges import started."

/orientdb/bin/oetl.sh /import/Youtube/friends.json

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "Youtube edges import ended. Total execution time: ${ELAPSED_TIME} seconds."

echo
echo
echo

START_TIME=$(date +%s)

echo "Youtube properties import started."

/orientdb/bin/oetl.sh /import/Youtube/properties.json

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "Youtube properties import ended. Total execution time: ${ELAPSED_TIME} seconds."
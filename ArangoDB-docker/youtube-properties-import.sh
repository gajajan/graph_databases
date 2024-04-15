#! /bin/sh

START_TIME=$(date +%s)

echo "Youtube properties import started."

/usr/bin/arangoimport --file "/csv/Youtube/properties.csv" --type csv --server.database "Youtube" --collection "User" --server.password "root" --on-duplicate "update" --translate "userId=_key"

END_TIME=$(date +%s)
PROPERTIES_IMPORT_TIME=$((END_TIME - START_TIME))
echo "Youtube properties import ended."

echo
echo
echo

echo "Youtube properties: Total execution time: ${PROPERTIES_IMPORT_TIME} seconds."
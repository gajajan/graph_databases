#! /bin/sh

START_TIME=$(date +%s)

echo "Youtube properties import started."

/orientdb/bin/oetl.sh /import/Youtube/properties.json

END_TIME=$(date +%s)
PROPERTIES_IMPORT_TIME=$((END_TIME - START_TIME))
echo "Youtube properties import ended."

echo
echo
echo

echo "Youtube properties: Total execution time: ${PROPERTIES_IMPORT_TIME} seconds."
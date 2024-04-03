#! /bin/sh

START_TIME=$(date +%s)

echo "RailNetwork import started."

/usr/bin/arangoimport --file /csv/RailNetwork/stations.csv --type csv --server.database "RailNetwork" --create-database true  --collection "Station" --create-collection true --translate "stationId=_key" --server.password "root"
/usr/bin/arangoimport --file /csv/RailNetwork/leads_to.csv --type csv --server.database "RailNetwork" --create-database true  --collection "LEADS_TO" --create-collection true --create-collection-type "edge" --from-collection-prefix "Station" --to-collection-prefix "Station" --translate "sourceId=_from" --translate "destId=_to" --server.password "root"

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "RailNetwork import ended. Total execution time: ${ELAPSED_TIME} seconds."

echo
echo
echo

START_TIME=$(date +%s)

echo "TravelEnthusiastNetwork import started."

/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/journeys.csv" --type csv --server.database "TravelEnthusiastNetwork" --create-database true --collection "Journey" --create-collection true --translate "journeyId=_key" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/countries.csv" --type csv --server.database "TravelEnthusiastNetwork" --create-database true --collection "Country" --create-collection true --translate "countryCode=_key" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/activities.csv" --type csv --server.database "TravelEnthusiastNetwork" --create-database true --collection "TravelActivity" --create-collection true --translate "activityId=_key" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/users.csv" --type csv --server.database "TravelEnthusiastNetwork" --create-database true --collection "User" --create-collection true --translate "userId=_key" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/ratings.csv" --type csv --server.database "TravelEnthusiastNetwork" --create-database true --collection "Rating" --create-collection true --translate "ratingId=_key" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/destinations.csv" --type csv --server.database "TravelEnthusiastNetwork" --create-database true --collection "Destination" --create-collection true --translate "destinationId=_key" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/follows.csv" --type csv --server.database "TravelEnthusiastNetwork" --collection "FOLLOWS"  --create-collection true --create-collection-type "edge" --from-collection-prefix "User" --to-collection-prefix "User" --translate "user1Id=_from" --translate "user2Id=_to" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/is_within.csv" --type csv --server.database "TravelEnthusiastNetwork" --collection "IS_WITHIN"  --create-collection true --create-collection-type "edge" --from-collection-prefix "Destination" --to-collection-prefix "Country" --translate "destinationId=_from" --translate "countryCode=_to" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/led_to.csv" --type csv --server.database "TravelEnthusiastNetwork" --collection "LED_TO"  --create-collection true --create-collection-type "edge" --from-collection-prefix "Journey" --to-collection-prefix "Destination" --translate "journeyId=_from" --translate "destinationId=_to" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/likes.csv" --type csv --server.database "TravelEnthusiastNetwork" --collection "LIKES"  --create-collection true --create-collection-type "edge" --from-collection-prefix "User" --to-collection-prefix "TravelActivity" --translate "userId=_from" --translate "activityId=_to" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/offers.csv" --type csv --server.database "TravelEnthusiastNetwork" --collection "OFFERS"  --create-collection true --create-collection-type "edge" --from-collection-prefix "Destination" --to-collection-prefix "TravelActivity" --translate "destinationId=_from" --translate "activityId=_to" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/participated.csv" --type csv --server.database "TravelEnthusiastNetwork" --collection "PARTICIPATED"  --create-collection true --create-collection-type "edge" --from-collection-prefix "User" --to-collection-prefix "Journey" --translate "userId=_from" --translate "journeyId=_to" --server.password "root"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/wrote_about.csv" --type csv --server.database "TravelEnthusiastNetwork" --collection "WROTE"  --create-collection true --create-collection-type "edge" --from-collection-prefix "User" --to-collection-prefix "Rating" --translate "userId=_from" --translate "ratingId=_to" --server.password "root" --remove-attribute "journeyId"
/usr/bin/arangoimport --file "/csv/TravelEnthusiastNetwork/wrote_about.csv" --type csv --server.database "TravelEnthusiastNetwork" --collection "ABOUT"  --create-collection true --create-collection-type "edge" --from-collection-prefix "Rating" --to-collection-prefix "Journey" --translate "ratingId=_from" --translate "journeyId=_to" --server.password "root" --remove-attribute "userId"

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))
echo "TravelEnthusiastNetwork import ended. Total execution time: ${ELAPSED_TIME} seconds."
FROM orientdb:3.2.28-tp3

ENV ORIENTDB_ROOT_PASSWORD=root

COPY csv /csv/
COPY import /import/
COPY youtube-import-test.sh /youtube-import-test.sh
COPY youtube-properties-import.sh /youtube-properties-import.sh
COPY init-files-gremlin /init-files-gremlin/

RUN /orientdb/bin/oetl.sh /import/RailNetwork/stations.json
RUN /orientdb/bin/oetl.sh /import/RailNetwork/leads_to.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/activities.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/countries.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/users.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/destinations.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/journeys.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/ratings.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/follows.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/is_within.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/led_to.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/likes.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/offers.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/participated.json
RUN /orientdb/bin/oetl.sh /import/TravelEnthusiastNetwork/wrote_about.json
FROM neo4j:5.18.1-enterprise

ENV NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
ENV NEO4J_AUTH=none
ENV NEO4J_PLUGINS='["apoc", "graph-data-science"]'

COPY csv /var/lib/neo4j/import
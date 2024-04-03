//parameters for connector
url = "embedded:/Users/gajaj/orientdb-tp3-3.2.23/databases/RailNetwork";
user = "root";
password = "root";

//OrientDb database connector
graph = OrientGraph.open(url, user, password);

//establishing a graph traversal source object
//for example we can retrieve graph vertices with g.V().valueMap()
g = graph.traversal();

def unweightedShortestPath(g, start, target, limit=1) {
    return g.withSack(0.0).
            V().
            has("Station", "stationId", start).
            repeat(outE("LEADS_TO").
                    sack(sum).
                        by("length").
                    inV().
                    simplePath()).
            until(has("Station", "stationId", target)).
            limit(limit).
            order().
                by(sack(), asc).
            project("stations", "stationsCount", "totalLength").
                by(path().
                    unfold().
                    hasLabel("Station").
                    values("stationName").
                    fold()).
                by(path().count(local).math('(_+1)/2')).
                by(sack())
}

def weightedShortestPath(g, start, target, limit=1) {
    return g.withSack(0.0).V().
            has("Station", "stationId", start).
            repeat(outE("LEADS_TO").
                    sack(sum).by("length").
                    inV().as("visited").
                    simplePath().
                    group("minDist").
                        by().by(sack().min()).
                    filter(project("currMinDist", "sackDist").
                            by(select("minDist").select(select("visited"))).
                            by(sack()).
                        where("currMinDist", eq("sackDist")))).
            until(has("Station", "stationId", target)).
            order().
                by(sack(), asc).
            limit(limit).
            project("stations", "stationsCount", "totalLength").
                by(path().
                    unfold().
                    hasLabel("Station").
                    values("stationName").
                    fold()).
                by(path().count(local).math('(_+1)/2')).
                by(sack())
}
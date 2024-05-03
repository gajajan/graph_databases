//parameters for connector
url = "plocal:/orientdb/databases/RailNetwork";
user = "root";
password = "root";

//OrientDb database connector
graph = OrientGraph.open(url, user, password);

//establishing a graph traversal source object
//for example we can retrieve graph vertices with g.V().valueMap()
g = graph.traversal();

//setting colors
:set string.color white
:set number.color cyan
:set vertex.color yellow
:set edge.color green

def help() {
    println "unweightedShortestPath(g, start=1048, target=319, limit=1)"
    println "\tFinds the unweighted shortest path between two railway stations."
    println "--------------------------------------------------------------------------------"
    println "weightedShortestPath(g, start=1048, target=319)"
    println "\tFinds the weighted shortest path between two railway stations."
}

def unweightedShortestPath(g, start=1048, target=319, limit=1) {
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
                by(sack()).
            fold()
}

def weightedShortestPath(g, start=1048, target=319) {
    return g.withSack(0.0).
            V().
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
            limit(1).
            project("stations", "stationsCount", "totalLength").
                by(path().
                    unfold().
                    hasLabel("Station").
                    values("stationName").
                    fold()).
                by(path().count(local).math('(_+1)/2')).
                by(sack()).
            fold()
}
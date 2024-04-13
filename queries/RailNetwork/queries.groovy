//QUERIES SEPARATED BY NAMES WITH CAPITAL LETTERS


//VARIABLES SETTING
src = 1048;
dst = 319;


//UNWEIGHTED SHORTEST PATH
//repeat().until() pattern uses barriers -> it executes eagerly using breadth-first search
g.V().has("Station", "stationId", src).
    repeat(out("LEADS_TO")).
    until(has("Station", "stationId", dst)).
    limit(1).
    path().
        by("stationName").as("stations").
    count(local).as("stationsOnPath").
    select("stations", "stationsOnPath")


//WEIGHTED SHORTEST PATH - naive
//not working -- computationally expensive
g.withSack(0.0).
    V().
    has("Station", "stationId", src).
    repeat(outE("LEADS_TO").
            sack(sum).
                by("length").
            inV().
            simplePath()).
    until(has("Station", "stationId", dst)).
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
        by(sack())


//WEIGHTED SHORTEST PATH
//optimization - something like Dijkstra
//group creates a "lookup table" with 2 columns - vertices and minDist
//so we keep the shortest distance found so far to each visited node
g.withSack(0.0).
    V().
    has("Station", "stationId", src).
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
    until(has("Station", "stationId", dst)).
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
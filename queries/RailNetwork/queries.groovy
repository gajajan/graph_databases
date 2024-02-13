//repeat().until() pattern uses barriers -> it executes eagerly using breadth-first search
g.V().has("Station", "stationId", 1048).
    repeat(out("LEADS_TO")).
    until(has("Station", "stationId", 319)).
    limit(1).
    path().
        by("stationName").as("stations").
    count(local).as("stationsOnPath").
    select("stations", "stationsOnPath")


g.withSack(0.0).
    V().
    has("Station", "stationId", 1048).
    repeat(outE("LEADS_TO").
            sack(sum).
                by("length").
            inV().
            simplePath()).
    until(has("Station", "stationId", 810)).
    limit(3).
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

//spatne -- computationally expensive
g.withSack(0.0).
    V().
    has("Station", "stationId", 1048).
    repeat(outE("LEADS_TO").
            sack(sum).
                by("length").
            inV().
            simplePath()).
    until(has("Station", "stationId", 319)).
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

//optimalizace - něco jako Dijkstra
//group vytvoří "lookup tabulku" se 2 sloupci - vrcholy a minDist
//udržujeme tedy dosud nejkratší vzdálenost nalezenou do každého navštíveného uzlu
g.withSack(0.0).
    V().
    has("Station", "stationId", 1048).
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
    until(has("Station", "stationId", 810)).
    order().
        by(sack(), asc).
    limit(3).
    project("stations", "stationsCount", "totalLength").
        by(path().
            unfold().
            hasLabel("Station").
            values("stationName").
            fold()).
        by(path().count(local).math('(_+1)/2')).
        by(sack()).
    fold()

//když omezíme počet zastávek...
g.withSack(0.0).
    V().
    has("Station", "stationId", 1048).
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
    until(has("Station", "stationId", 319)).
    where(path().count(local).is(lt(20))).
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
graph = OrientGraph.open("remote:localhost/TravelEnthusiastNetwork", "root", "root");
g = graph.traversal();

// first neighborhood
user_id = 10;
g.V().has("User", "userId", user_id). \
    out("FOLLOWS"). \
    valueMap();

//second neighborhood
g.V().has("User", "userId", user_id). \
    out("FOLLOWS").aggregate("first_neighborhood"). \
    out("FOLLOWS"). \
    dedup(). \
        where(neq("first_neighborhood")). \
    valueMap();

//second neighborhood without first neighborhood
g.V().has("User", "userId", user_id).
    out("FOLLOWS").
    out("FOLLOWS").
    valueMap();
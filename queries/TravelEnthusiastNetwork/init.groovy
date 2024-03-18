import groovy.transform.Field

//parameters for connector
url = "embedded:/Users/gajaj/orientdb-tp3-3.2.23/databases/TravelEnthusiastNetwork";
user = "root";
password = "root";

//OrientDb database connector
graph = OrientGraph.open(url, user, password);

//establishing a graph traversal source object
//for example we can retrieve graph vertices with g.V().valueMap()
g = graph.traversal();

def getFirstNeighborhood(g, userId) {
    return g.V().has('User', 'userId', userId).out('FOLLOWS').valueMap()
}

def getSecondNeighborhood(g, userId) {
    return g.V().has("User", "userId", userId).
            out("FOLLOWS").
            out("FOLLOWS").
            dedup().
            valueMap();
}

def getSecondNeighborhoodWithoutFirst(g, userId) {
    return g.V().has("User", "userId", userId).
            match(__.as('me').out('FOLLOWS').as('f'), 
                __.as('f').out('FOLLOWS').where(neq('me')).as('fof'),
                __.not(__.as('me').out('FOLLOWS').as('fof'))).
            select('fof').
            dedup().
            valueMap()
}

def getTravelBuddies(g, userId){
    return g.V().has("User", "userId", userId).as("me").
            out("PARTICIPATED").
            in("PARTICIPATED").
            dedup().
            where(neq("me")).
            valueMap()
}

def getVisitedDestinations(g, userId){
    return g.V().has("User", "userId", userId).
            out("PARTICIPATED").
            out("LED_TO").
            groupCount().
                by("destinationName").
            unfold().
            order().
                by(values, desc).
                by(keys).
            project("destinationName", "count").
                by(keys).
                by(values)
}

def getDestinationsByActivities(g, userId) {
    return g.V().has('User', 'userId', userId).as('u').
            out('LIKES').as('a').
            in('OFFERS').as('d').
            not(where(__.in('LED_TO').in('PARTICIPATED').as('u'))).
            groupCount().
                by("destinationName").
            unfold().
            order().
                by(values, desc).
                by(keys).
            project("destinationName", "count").
                by(keys).
                by(values)
}

def getDestinationsByActivityList(g, activityList) {
    return g.V().hasLabel('Destination').as('d').
            where(
                out('OFFERS').
                has('TravelActivity', 'activityName', within(activityList)).
                count().
                is(eq(activityList.size()))
            ).
            valueMap()
}

def recommendDestinationsByActivityList(g, userId, activityList) {
    return g.V().has('User', 'userId', userId).as('u').
            V().hasLabel('Destination').as('d').
            where(
                out('OFFERS').
                has('TravelActivity', 'activityName', within(activityList)).
                count().
                is(eq(activityList.size()))
            ).
            not(where(__.in('LED_TO').in('PARTICIPATED').as('u'))).
            group().
                by(identity()).
                by(coalesce(__.in('LED_TO').
                                in('ABOUT').
                                values('rating').mean(), 
                                constant(0))).
            unfold().
            order().
                by(values, desc).
            limit(3).
            project('destinationId', 'destinationName', 'rating').
                by(select(keys).values('destinationId')).
                by(select(keys).values('destinationName')).
                by(choose(select(values)).
                    option(gt(0), (select(values))).
                    option(0, constant('Not rated.')))
}

def favouriteMonth(g, destinationId) {
    return g.V().has("Destination", "destinationId", destinationId).
            in("LED_TO").
            group().
                by(values('journeyStart').
                    map{it.get().getMonth() + 1 }).
                by(coalesce(__.in('ABOUT').
                            values('rating').mean(), 
                            constant(0))).
            unfold().
            order().
                by(values, desc).
            limit(1).
            project("Month", "Rating").
                by(keys).
                by(choose(select(values)).
                    option(gt(0), (select(values))).
                    option(0, constant('Not rated.')))
}

def searchUsers(g, substr) {
    return g.V().hasLabel("User").
            or(
                has("firstName", TextP.regex("(?i)" + substr)),
                has("lastName", TextP.regex("(?i)" + substr))
            ).
            dedup().
            valueMap()
}
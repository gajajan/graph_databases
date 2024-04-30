
//parameters for connector
url = "plocal:/orientdb/databases/TravelEnthusiastNetwork";
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
    println "firstNeighborhood(g, userId=10)"
    println "\tReturns the first neighborhood of a user with specified userId."
    println "--------------------------------------------------------------------------------"
    println "secondNeighborhood(g, userId=10)"
    println "\tReturns the second neighborhood of a user with specified userId."
    println "--------------------------------------------------------------------------------"
    println "secondNeighborhoodWithoutFirst(g, userId=10)"
    println "\tReturns the second neighborhood of a user with specified userId, excluding the first neighborhood."
    println "--------------------------------------------------------------------------------"
    println "coTravelers(g, userId=10)"
    println "\tReturns co-travelers of a user with specified userId."
    println "--------------------------------------------------------------------------------"
    println "visitedDestinations(g, userId=10)"
    println "\tReturns visited destinations of a user with specified userId and the count of visits."
    println "--------------------------------------------------------------------------------"
    println "destinationsByFavouriteActivities(g, userId=10)"
    println "\tReturns destinations based on activities liked by the user."
    println "--------------------------------------------------------------------------------"
    println "destinationsByActivityList(g, activityList=['Sightseeing', 'Water Sports'])"
    println "\tReturns destinations based on a list of activities."
    println "--------------------------------------------------------------------------------"
    println "recommendDestinationsByActivityList(g, userId=10, activityList=['Sightseeing', 'Water Sports'])"
    println "\tRecommends destinations to a user based on a list of activities and ratings."
    println "--------------------------------------------------------------------------------"
    println "recommendDestinationsByFavouriteActivities(g, userId=10)"
    println "\tRecommends destinations to a user based on activities liked by the user and ratings."
    println "--------------------------------------------------------------------------------"
    println "favouriteMonth(g, destinationId=7)"
    println "\tReturns the favorite month for a given destination based on ratings."
    println "--------------------------------------------------------------------------------"
    println "searchUsers(g, substr='RoB')"
    println "\tSearches for users based on a substring of their first name or last name."
}

def firstNeighborhood(g, userId=10) {
    return g.V().has('User', 'userId', userId).out('FOLLOWS').valueMap();
}

def secondNeighborhood(g, userId=10) {
    return g.V().has("User", "userId", userId).
            out("FOLLOWS").
            out("FOLLOWS").
            dedup().
            valueMap();
}

def secondNeighborhoodWithoutFirst(g, userId=10) {
    return g.V().has("User", "userId", userId).
            match(__.as('me').out('FOLLOWS').as('f'), 
                __.as('f').out('FOLLOWS').where(neq('me')).as('fof'),
                __.not(__.as('me').out('FOLLOWS').as('fof'))).
            select('fof').
            dedup().
            valueMap();
}

def coTravelers(g, userId=10){
    return g.V().has("User", "userId", user).as("me").
            out("PARTICIPATED").
            in("PARTICIPATED").
            where(neq("me")).
            groupCount().
                by().
            unfold().
            order().
                by(select(keys).values('firstName')).
                by(select(keys).values('lastName')).
            project("firstName", "lastName", "count").
                by(select(keys).values('firstName')).
                by(select(keys).values('lastName')).
                by(values);
}

def visitedDestinations(g, userId=10){
    return g.V().has("User", "userId", userId).
            out("PARTICIPATED").
            out("LED_TO").
            groupCount().
                by("destinationName").
            unfold().
            order().
                by(values, desc).
                by(keys).
            project("name", "count").
                by(keys).
                by(values);
}

def destinationsByFavouriteActivities(g, userId=10) {
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
            project("name", "count").
                by(keys).
                by(values);
}

def destinationsByActivityList(g, activityList=["Sightseeing", "Water Sports"]) {
    return g.V().hasLabel('Destination').as('d').
            where(
                out('OFFERS').
                has('TravelActivity', 'activityName', within(activityList)).
                count().
                is(eq(activityList.size()))
            ).
            valueMap();
}

def recommendDestinationsByActivityList(g, userId=10, activityList=["Sightseeing", "Water Sports"]) {
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
                    option(0, constant('Not rated.')));
}

def recommendDestinationsByFavouriteActivities(g, userId=10) {
    return g.V().has('User', 'userId', userId).as('u').
            out('LIKES').
            in('OFFERS').as('d').
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
            project('name', 'rating').
                by(select(keys).values('destinationName')).
                by(choose(select(values)).
                    option(gt(0), (select(values))).
                    option(0, constant('Not rated.')));
}

def favouriteMonth(g, destinationId=7) {
    return g.V().has("Destination", "destinationId", destination).
            inE("LED_TO").
            group().by(values("startDate").map{it.get().getMonth() + 1}).
            unfold().
            project("month", "rating").
                by(keys).
                by(select(values).unfold().
                    outV().in('ABOUT').values('rating').mean().fold().
                    coalesce(unfold(),constant('not rated'))).
            order().
                by(__.select("rating").map { it.get() instanceof Number ? 0 : 1 }).
                by(__.select("rating"), desc).
            limit(3);
}

def searchUsers(g, substr="RoB") {
    return g.V().hasLabel("User").
            or(
                has("firstName", TextP.regex("(?i)" + substr)),
                has("lastName", TextP.regex("(?i)" + substr))
            ).
            dedup().
            valueMap();
}
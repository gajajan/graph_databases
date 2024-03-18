//USERS'S NEIGHBORHOOD

//variable for user id in this example
userId = 10;

// first neighborhood
g.V().has("User", "userId", userId). \
    out("FOLLOWS"). \
    valueMap();

//second neighborhood
g.V().has("User", "userId", userId).
    out("FOLLOWS").
    out("FOLLOWS").
    dedup().
    valueMap();

//second neighborhood without first neighborhood
g.V().has("User", "userId", userId).
    match(__.as('me').out('FOLLOWS').as('f'), 
        __.as('f').out('FOLLOWS').where(neq('me')).as('fof'),
        __.not(__.as('me').out('FOLLOWS').as('fof'))).
        select('fof').dedup().valueMap()


// DESTINATION RECOMMENDATION

// returns a list of destinations containing a destination and
// number indicating how many activities has the destination with specific user in common 
g.V().has('User', 'userId', userId).as('u').
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
        by(values).
    fold()

//returns destinations which offers activities in list
activityList = ["Sightseeing", "Water Sports"]

g.V().hasLabel('Destination').as('d').
    where(
        out('OFFERS').
        has('TravelActivity', 'activityName', within(activityList)).
        count().
        is(eq(activityList.size()))
    ).
    valueMap()

//offers 3 destinations that the user hasnt visited
//returns a list of lists containing destination's properties and
// rating of this destination
g.V().has('User', 'userId', userId).as('u').
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
            option(0, constant('Not rated.'))).
    fold()

//USER'S VISITED DESTINATIONS

//returns a list of lists containing a destination and
// a number indicating how many times user visited specific destination
g.V().has("User", "userId", userId).
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
        by(values).
    fold()


//USER'S TRAVEL BUDDIES

//returns users map
g.V().has("User", "userId", userId).
    as("me").
    out("PARTICIPATED").
    in("PARTICIPATED").
    dedup().
        where(neq("me")).
    valueMap()


//THE MOST FAVOURITE MONTH FOR VISITING SPECIFIC DESTINATION

//returns number indicating month in year
destination = "Olomouc"
g.V().has("Destination", "destinationName", destination).
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

//TEXT SEARCH

substr = "on";

//case sensitive
g.V().hasLabel("User").
    or(
        has("firstName",containing(substr)),
        has("lastName", containing(substr))).
    dedup().
    valueMap();

//ignoring case
g.V().hasLabel("User").
    or(
        has("firstName", TextP.regex("(?i)" + substr)),
        has("lastName", TextP.regex("(?i)" + substr))
    ).
    dedup().
    valueMap();
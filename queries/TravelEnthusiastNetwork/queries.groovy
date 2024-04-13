//QUERIES SEPARATED BY NAMES WITH CAPITAL LETTERS


//VARIABLES SETTING
user = 10;
activityList = ["Sightseeing", "Water Sports"];
destination = 56;
substr = "RoB";


//FIRST NEIGHBORHOOD
g.V().has("User", "userId", user).
    out("FOLLOWS").
    valueMap();


//SECOND NEIGHBORHOOD
g.V().has("User", "userId", user).
    out("FOLLOWS").
    out("FOLLOWS").
    dedup().
    valueMap();


//SECOND NEIGHBORHOOD WITHOUT FIRST
g.V().has("User", "userId", user).
    match(__.as('me').out('FOLLOWS').as('f'), 
        __.as('f').out('FOLLOWS').where(neq('me')).as('fof'),
        __.not(__.as('me').out('FOLLOWS').as('fof'))).
        select('fof').dedup().valueMap();

//VISITED DESTINATIONS
//returns a destination name and
// a number indicating how many times user visited specific destination
g.V().has("User", "userId", user).
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
        by(values);


//CO-TRAVELERS
//returns users map
g.V().has("User", "userId", user).
    as("me").
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


//DESTINATIONS OFFERING ALL ACTIVITIES IN LIST
g.V().hasLabel('Destination').as('d').
    where(
        out('OFFERS').
        has('TravelActivity', 'activityName', within(activityList)).
        count().
        is(eq(activityList.size()))).
    valueMap();


//DESTINATION RECOMMENDATION BASED ON ACTIVITY LIST
//offers 3 destinations that the user has not visited
//the destination must offer all activities whose name is in the input list
//returns the destination names and their rating sorted by average rating
g.V().has('User', 'userId', user).as('u').
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
    project('name', 'rating').
        by(select(keys).values('destinationName')).
        by(choose(select(values)).
            option(gt(0), (select(values))).
            option(0, constant('Not rated.')));


//DESTINATIONS OFFERING ACTIVITIES THAT USER LIKES
// returns a a destinations and
// number indicating how many activities has the destination with specific user in common 
g.V().has('User', 'userId', user).
    out('LIKES').as('a').
    in('OFFERS').as('d').
    groupCount().
        by("destinationName").
    unfold().
    order().
        by(values, desc).
        by(keys).
    project("name", "count").
        by(keys).
        by(values);


//DESTINATION RECOMMENDATION BASED ON USER'S FAVOURITE ACTIVITIES
g.V().has('User', 'userId', user).as('u').
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


//THE MOST FAVOURITE MONTH FOR VISITING SPECIFIC DESTINATION
//returns a number indicating the month of the year
//and the input destination rating for that month
g.V().has("Destination", "destinationId", destination).
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
            option(0, constant('Not rated.')));


//TEXT SEARCH
//returns users whose name contains the input substring
//case sensitive!
g.V().hasLabel("User").
    or(
        has("firstName",containing(substr)),
        has("lastName", containing(substr))).
    dedup().
    valueMap();

//TEXT SEARCH
//returns users whose name contains the input substring
g.V().hasLabel("User").
    or(has("firstName", TextP.regex("(?i)" + substr)),
        has("lastName", TextP.regex("(?i)" + substr))).
    dedup().
    valueMap();
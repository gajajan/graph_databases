//USERS'S NEIGHBORHOOD

//variable for user id in this example
user_id = 10;

// first neighborhood
g.V().has("User", "userId", user_id). \
    out("FOLLOWS"). \
    valueMap();

//second neighborhood
g.V().has("User", "userId", user_id).
    out("FOLLOWS").
    out("FOLLOWS").
    dedup().
    valueMap();

//second neighborhood without first neighborhood
g.V().has("User", "userId", user_id).
    match(__.as('me').out('FOLLOWS').as('f'), 
        __.as('f').out('FOLLOWS').where(neq('me')).as('fof'),
        __.not(__.as('me').out('FOLLOWS').as('fof'))).
        select('fof').dedup().valueMap()


// DESTINATION RECOMMENDATION

// returns a list of destinations containing a destination and
// number indicating how many activities has the destination with specific user in common 
g.V().has('User', 'userId', user_id).as('u').
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
activity_list = ["Sightseeing", "Water Sports"]
user_id = 5

g.V().hasLabel('Destination').as('d').
    where(
        out('OFFERS').
        has('TravelActivity', 'activityName', within(activity_list)).
        count().
        is(eq(activity_list.size()))
    ).
    valueMap()

//offers 3 destinations that the user hasnt visited
//returns a list of lists containing destination's properties and
// rating of this destination
g.V().has('User', 'userId', user_id).as('u').
    V().hasLabel('Destination').as('d').
    where(
        out('OFFERS').
        has('TravelActivity', 'activityName', within(activity_list)).
        count().
        is(eq(activity_list.size()))
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
g.V().has("User", "userId", user_id).
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
g.V().has("User", "userId", user_id).
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

//TRIP ANNIVERSARY

//current date
currentDate = new Date()
//we have to recalculate the current date
currentMonthDay = currentDate.getMonth() * 100 + currentDate.getDate()

//this returns ids of users who has trip anniversary
g.E().hasLabel('LED_TO').
  where(
    and(
      where((map { 
        def startDate = it.get().value('startDate')
        return startDate.getMonth() * 100 + startDate.getDate()
      }).is(lte(currentMonthDay))),
      where((map { 
        def endDate = it.get().value('endDate')
        return endDate.getMonth() * 100 + endDate.getDate()
      }).is(gte(currentMonthDay)))
    )
  ).
  outV().
  in('PARTICIPATED').
  dedup().
  values('userId')

//sets userId variable to random user's property `userId`
user_id = g.E().hasLabel('LED_TO').
  where(
    and(
      where((map { 
        def startDate = it.get().value('startDate')
        return startDate.getMonth() * 100 + startDate.getDate()
      }).is(lte(currentMonthDay))),
      where((map { 
        def endDate = it.get().value('endDate')
        return endDate.getMonth() * 100 + endDate.getDate()
      }).is(gte(currentMonthDay)))
    )
  ).
  outV().
  in('PARTICIPATED').
  dedup().
  sample(1).
  values('userId').
  next()
    
//uses userId variable from previous query
//returns a list of lists containing a destination and
// a number indicating how many years have passed since the trip
g.V().has("User", "userId", user_id).
    out("PARTICIPATED").
    outE('LED_TO').
    project('destination', 'years').
        by(inV().values('destinationName')).
        by(map { 
            def startDate = it.get().value('startDate')
            def endDate = it.get().value('endDate')
            def currentDate = new Date()
            
            def startMonthDay = startDate.getMonth() * 100 + startDate.getDate()
            def currentMonthDay = currentDate.getMonth() * 100 + currentDate.getDate()
            
            if (startMonthDay <= currentMonthDay && currentMonthDay <= (endDate.getMonth() * 100 + endDate.getDate())) {
                def yearsDifference = currentDate.getYear() - startDate.getYear()
                return yearsDifference
            }
            else {
                return -1
            }
        }).
    where(select('years').is(gt(0))).
    fold()
    
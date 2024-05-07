//DOTAZY ODDELENY POMOCI NAZVU S VELKYMI PISMENY


//VARIABLES SETTING
user = 10;
activityList = ["Sightseeing", "Water Sports"];
destination = 61;
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
//vrací jméno destinace
// a počet indikující kolikrát uživatel danou destinaci navstivil
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
g.V().has("User", "userId", user).as("me").
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
//nabízí 3 destinace které uživatel nenavštívil
//tato destinace musí nabízet všechny aktivity formulované v activityList
//dotaz vrací jméno destinace a její hodnocení, seřazené podle hodnocení
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
// vrací destinaci a
// cislo indikujici kolik aktivit ma destinace s uzivatelem spolecne
g.V().has('User', 'userId', user).as('u').
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
//vrací cislo reprezentujici mesic v roce a hodnoceni
//vysledek je serazen podle hodnoceni a omezen na 3
g.V().has("Destination", "destinationId", destination).
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
  limit(3)

//TEXT SEARCH
//vraci uzivatele jejichz jmeno obsahuje vstupni retezec
//case sensitive!
g.V().hasLabel("User").
    or(
        has("firstName",containing(substr)),
        has("lastName", containing(substr))).
    dedup().
    valueMap();

//TEXT SEARCH
//vraci uzivatele jejichz jmeno obsahuje vstupni retezec
g.V().hasLabel("User").
    or(has("firstName", TextP.regex("(?i)" + substr)),
        has("lastName", TextP.regex("(?i)" + substr))).
    dedup().
    valueMap();
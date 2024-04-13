//Q1 - Q4
//depth x is specified in times(x)
g.V().has("User", "userId", 1).as('me').
    repeat(both()).
    emit().times(3).
    where(neq('me')).
    dedup().count().
           
//Q5
g.V().has("User", "userId", 12000).
    repeat(both().simplePath()).
    until(has("User", "userId", 1047)).
    limit(1).path()

//Q6
g.V().has("User", "userId", 12000).
    repeat(out().simplePath()).
    until(has("User", "userId", 1047)).
    limit(1).path()

//Q7
g.V().filter{
    it.get().value('firstName').startsWith('Ma') && 
    it.get().value('age') > 75 }.
    count()

//Q8
g.V().has("User", "firstName", "James").
    values("age").
    mean()
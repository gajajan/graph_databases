clockWithResult(1){
    g.V().has("User", "userId", 1).as('me').
        repeat(both()).
        emit().times(2).
        where(neq('me')).
        dedup().count().
        next()
} 
           
clockWithResult(1){
    g.V().has("User", "userId", 12000).
    repeat(out().simplePath()).
    until(has("User", "userId", 1047)).
    limit(1).path().next()
}

clockWithResult(1){
    def iterator = g.V().has("User", "userId", 12000).
        repeat(out().simplePath()).
        until(has("User", "userId", 1047).or().loops().is(10)).
        has("User", "userId", 1047).
        limit(1).
        path()

    def result = iterator.hasNext() ? iterator.next() : 'path doesnt exist'
    result
}

clockWithResult(1){
    g.V().hasLabel('User').has('firstName', TextP.startingWith('Ma')).has('age', gt(75)).count().next()
}

clockWithResult(1){
    g.V().filter{ it.get().value('firstName').startsWith('Ma') && it.get().value('age') > 75 }.count().next()
}
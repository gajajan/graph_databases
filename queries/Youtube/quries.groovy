clockWithResult(1){
    g.V().has("User", "userId", 1).as('me').
        repeat(both()).
        emit().times(5).
        where(neq('me')).
        dedup().count().
        next()
} 


g.V().project("v","degree").by(values("userId")).by(bothE().count()).
           order().by("degree", desc).
           limit(4)
           
clockWithResult(1){
    g.V().has("User", "userId", 12000).
    repeat(both().simplePath()).
    until(has("User", "userId", 1047)).
    limit(1).path().next()
}
import groovy.time.*

//parameters for connector
url = "embedded:/Users/gajaj/orientdb-tp3-3.2.23/databases/Youtube";
user = "root";
password = "root";

//OrientDb database connector
graph = OrientGraph.open(url, user, password);

//establishing a graph traversal source object
//for example we can retrieve graph vertices with g.V().valueMap()
g = graph.traversal();

def countMNeighborhood(g, userId, m) {
    def timeStart = new Date()
    result = g.V().has("User", "userId", userId).as('me').
                repeat(both()).
                emit().times(m).
                where(neq('me')).
                dedup().count().next()
    def timeStop = new Date()
    TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
    return "duration: ${duration}, count: ${result}"
}

def shortestPathBoth(g, start, target) {
    def timeStart = new Date()
    result = g.V().has("User", "userId", start).
                repeat(both().simplePath()).
                until(has("User", "userId", target)).
                limit(1).path().next()
    def timeStop = new Date()
    TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
    return "duration: ${duration}, result: ${result}"
}

def shortestPathOut(g, start, target) {
    def timeStart = new Date()
    result = g.V().has("User", "userId", start).
                repeat(out().simplePath()).
                until(has("User", "userId", target)).
                limit(1).path().next()
    def timeStop = new Date()
    TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
    return "duration: ${duration}, result: ${result}"
}

def shortestPathOutLimited(g, start, target, limit=5) {
    def timeStart = new Date()

    def iterator = g.V().has("User", "userId", start).
        repeat(out().simplePath()).
        until(has("User", "userId", target).or().loops().is(limit)).
        has("User", "userId", target).
        limit(1).
        path()

    def result = iterator.hasNext() ? iterator.next() : 'path doesnt exist'

    def timeStop = new Date()
    TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
    return "duration: ${duration}, result: ${result}"
}
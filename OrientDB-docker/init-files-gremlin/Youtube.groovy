import groovy.time.*

//parameters for connector
url = "plocal:/orientdb/databases/Youtube";
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
    println "countMNeighborhood(g, m, userId=1)"
    println "\tCounts the number of vertices up to the M-neighborhood of a given user."
    println "--------------------------------------------------------------------------------"
    println "shortestPathBoth(g, start=12000, target=1047)"
    println "\tFinds the shortest path between two users using both incoming and outgoing edges."
    println "--------------------------------------------------------------------------------"
    println "shortestPathOut(g, start=12000, target=1047)"
    println "\tFinds the shortest path between two users using only outgoing edges."
    println "--------------------------------------------------------------------------------"
    println "shortestPathOutLimited(g, start=12000, target=1047, limit=5)"
    println "\tFinds the shortest path between two users using only outgoing edges, with a specified limit on the number of steps."
    println "--------------------------------------------------------------------------------"
    println "countUsers(g, substr='Ma', age=75)"
    println "\tCounts the number of users whose first name starts with a given substring and age is greater than a specified value."
    println "--------------------------------------------------------------------------------"
    println "averageAge(g, name='James')"
    println "\tCalculates the average age of users with a specified first name."
}

//Q1-4
def countMNeighborhood(g, m, userId=1) {
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

//Q5
def shortestPathBoth(g, start=12000, target=1047) {
    def timeStart = new Date()
    def iterator = g.V().has("User", "userId", start).
                repeat(both().simplePath()).
                until(has("User", "userId", target)).
                limit(1).path()

    def result = iterator.hasNext() ? iterator.next() : 'path doesnt exist'

    def timeStop = new Date()
    TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
    return "duration: ${duration}, result: ${result}"
}

//Q6
def shortestPathOut(g, start=12000, target=1047) {
    def timeStart = new Date()
    def iterator = g.V().has("User", "userId", start).
                repeat(out().simplePath()).
                until(has("User", "userId", target)).
                limit(1).path()

    def result = iterator.hasNext() ? iterator.next() : 'path doesnt exist'
    
    def timeStop = new Date()
    TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
    return "duration: ${duration}, result: ${result}"
}

def shortestPathOutLimited(g, start=12000, target=1047, limit=5) {
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

//Q7
def countUsers(g, substr="Ma", age=75) {
    def timeStart = new Date()

    result = g.V().filter{
        it.get().value('firstName').startsWith(substr) && 
        it.get().value('age') > age }.
        count().next()

    def timeStop = new Date()
    TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
    return "duration: ${duration}, result: ${result}"
}

//Q8
def averageAge(g, name="James") {
    def timeStart = new Date()

    result = g.V().has("User", "firstName", "James").
        values("age").
        mean().next()

    def timeStop = new Date()
    TimeDuration duration = TimeCategory.minus(timeStop, timeStart)
    return "duration: ${duration}, result: ${result}"
}
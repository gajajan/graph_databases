--Q1,Q2,Q3,Q4
SELECT count(*)
FROM (TRAVERSE both("FRIENDS") FROM (SELECT * FROM User WHERE userId = 1) MAXDEPTH 2)
WHERE $depth > 0

--Q5,Q6
SELECT expand(path) FROM (
  SELECT shortestPath($from, $to) AS path 
  LET 
    $from = (SELECT FROM User WHERE userId=12000), 
    $to = (SELECT FROM User WHERE userId=7357) 
  UNWIND path
)

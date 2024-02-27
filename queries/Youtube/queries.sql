SELECT count(distinct(*))
FROM (TRAVERSE both("FRIENDS") FROM (SELECT * FROM User WHERE userId = 2) MAXDEPTH 2)
WHERE $depth > 0


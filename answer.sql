-- TYPE YOUR SQL QUERY BELOW

-- PART 1: Create a SQL query that maps out the daily average users before and after the feature change

-- Find number of total daily users (measured as unique daily logins) before and after 2018-06-02 00:00
-- Format: {total unique daily logins}|{length of time}|{average unique daily logins per day}
-- (before followed by after)
SELECT 
  SUM(uid),
  CAST((JULIANDAY(MAX(ts)) - JULIANDAY(MIN(ts))) AS INTEGER), 
  CAST(SUM(uid) AS REAL) / CAST((JULIANDAY(MAX(ts)) - JULIANDAY(MIN(ts))) AS INTEGER)
FROM (
  SELECT DATE(login_timestamp, "unixepoch") AS ts, COUNT(DISTINCT user_id) AS uid
  FROM login_history
  WHERE ts < DATE("2018-06-02") 
  GROUP BY ts
)
UNION
SELECT 
  SUM(uid),
  CAST((JULIANDAY(MAX(ts)) - JULIANDAY(MIN(ts))) AS INTEGER), 
  CAST(SUM(uid) AS REAL) / CAST((JULIANDAY(MAX(ts)) - JULIANDAY(MIN(ts))) AS INTEGER)
FROM (
  SELECT DATE(login_timestamp, "unixepoch") AS ts, COUNT(DISTINCT user_id) AS uid
  FROM login_history
  WHERE ts >= DATE("2018-06-02") 
  GROUP BY ts
);

-- BONUS
--   To make a nice-looking graph, it's helpful to have a list of the actual number of daily users.
--   This requires a calendar table which we can left-join with the actual login table
-- NB output this to a file - it's a few hundred rows
WITH RECURSIVE dates(date) AS (
  VALUES('2018-03-02')
  UNION ALL
  SELECT DATE(date, '+1 day')
  FROM dates
  WHERE date <= '2019-02-01'
)
SELECT date AS ts, COUNT(DISTINCT user_id) AS uid
FROM dates
LEFT JOIN login_history ON DATE(dates.date) = DATE(login_timestamp, "unixepoch")
GROUP BY date;


-- PART 2: Create a SQL query that indicates the number of status changes by card
-- Simply get total and average card count by ID
SELECT SUM(count), AVG(count)
FROM (
  SELECT COUNT(*) AS count
  FROM card_change_history
  INNER JOIN card ON card.id = card_change_history.cardId
  GROUP BY card.id
);

-- Get all counts to output to file
SELECT COUNT(*) AS count
FROM card_change_history
INNER JOIN card ON card.id = card_change_history.cardId
GROUP BY card.id
ORDER BY count DESC;


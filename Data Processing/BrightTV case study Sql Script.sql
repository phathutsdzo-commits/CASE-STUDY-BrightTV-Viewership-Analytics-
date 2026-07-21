-- Databricks notebook source
---Cleaning User Profile Table-------
-------------------------------------------------------------------
----- viewing the whole table before i start doing analysis
-------------------------------------------------------------------------
SELECT *
FROM brighttvcasestudy.default.brighttvdatasetuserprofile
LIMIT 10;
-------------------------------------------------------------------
-------Checking the size of the data------------
------------------------------------------------------------------
SELECT COUNT(*) AS number_of_rows,
       COUNT(DISTINCT UserID) as number_subscribers
from brighttvcasestudy.default.brighttvdatasetuserprofile;
-------------------------------------------------------------------
------ checking duplicate records based UserID column---
--------------------------------------------------------------------------
SELECT UserID,
       COUNT(*) AS duplicate_count
FROM brighttvcasestudy.default.brighttvdatasetuserprofile
GROUP BY UserID
HAVING COUNT(*) > 1;
--------------------------------------------------------------------
--------CHECKING IF THERE ARE ROWS WHERE THE USERID IS NULL
------------------------------------------------------------------
SELECT COUNT(*)
FROM brighttvcasestudy.default.brighttvdatasetuserprofile
WHERE UserID IS NULL;
---------------------------------------------------------------------------
----- Gender checks -------------------------
------------------------------------------------------------------------------
SELECT DISTINCT gender
FROM brighttvcasestudy.default.brighttvdatasetuserprofile;

SELECT COUNT(*)
FROM brighttvcasestudy.default.brighttvdatasetuserprofile
WHERE gender=' ';
--------------------------------------------------------------------------
----combining none, other or null to read as unknown
-------------------------------------------------------------
SELECT
    Gender_Group,
    COUNT(*) AS CNT,
    COUNT(DISTINCT UserID) AS Subscribers
FROM (
    SELECT
        UserID,
        CASE
            WHEN Gender IS NULL OR TRIM(Gender) = '' THEN 'Unknown'
            WHEN Gender ILIKE '%none%' THEN 'Unknown'
            ELSE Gender
        END AS Gender_Group
    FROM brighttvcasestudy.default.brighttvdatasetuserprofile
) t
GROUP BY Gender_Group;
---------------------------------------------------------------------
------------Race checks--------------
-----------------------------------------------------------------------------
SELECT DISTINCT Race 
FROM brighttvcasestudy.default.brighttvdatasetuserprofile;
--------------------------------------------------------------------------
----combining none, other  and empty space to read as unknown
------------------------------------------------------------------
SELECT
    Ethnicity_Group,
    COUNT(*) AS CNT,
    COUNT(DISTINCT UserID) AS Subscribers
FROM (
    SELECT
        UserID,
        CASE
            WHEN Race ILIKE '%other%' THEN 'Unknown'
            WHEN Race IS NULL OR TRIM(Race) = '' THEN 'Unknown'
            WHEN Race ILIKE '%none%' THEN 'Unknown'
            ELSE Race
        END AS Ethnicity_Group
    FROM brighttvcasestudy.default.brighttvdatasetuserprofile
) t
GROUP BY Ethnicity_Group;
-------------------------------------------------------
---Provine checks 
------------------------------------------------------------
SELECT DISTINCT Province
FROM brighttvcasestudy.default.brighttvdatasetuserprofile;
-----------------------------------------------------------------------
------combibing  none and empty space to read as uncategorized 
-------------------------------------------------------------------------------
SELECT
    Region,
    COUNT(*) AS CNT,
    COUNT(DISTINCT UserID) AS Subscribers
FROM (
    SELECT
        UserID,
        CASE
            WHEN Province ILIKE '%none%' THEN 'Uncategorized'
            WHEN Province IS NULL OR TRIM(Province) = '' THEN 'Uncategorized'
         ELSE Province
        END AS Region
       FROM brighttvcasestudy.default.brighttvdatasetuserprofile
) t
GROUP BY region;
-------------------------------------------------------------
-----AGE CHECKS
----------------------------------------
SELECT MIN(Age) as min_age,---=0
        MAX(AGE) as max_age----114
FROM brighttvcasestudy.default.brighttvdatasetuserprofile;
----------------------------------------------------------------------------
----check if there's a row where age is null
-------------------------------------------------------------------------------
select COUNT(*) AS cnt
FROM brighttvcasestudy.default.brighttvdatasetuserprofile
WHERE age IS NULL;
------------------------------------------------------------------------
---creating age groups
---------------------------------------------------------------

SELECT
    Age_Groups,
    COUNT(DISTINCT UserID) AS Subs
FROM (
    SELECT
        UserID,
        CASE
             WHEN Age BETWEEN 0 AND 12 THEN 'Kids'
        WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN Age BETWEEN 20 AND 34 THEN 'Young Adult'
        WHEN Age BETWEEN 35 AND 49 THEN 'Adult'
        WHEN Age BETWEEN 50 AND 64 THEN 'Middle-Aged'
        
    ELSE 'Senior'
        END AS Age_Groups
    FROM brighttvcasestudy.default.brighttvdatasetuserprofile
) t
GROUP BY Age_Groups;
---------------------------------------------------------------
-----creating a table from cleaned data (user profile table)
---------------------------------------------------------------
WITH cte1 AS (
    SELECT
        UserID,
        Age,

        CASE
            WHEN Province ILIKE '%none%'
                 OR Province IS NULL
                 OR TRIM(Province) = ''
            THEN 'Uncategorized'
            ELSE Province
        END AS Region,

        CASE
            WHEN Race ILIKE '%other%'
                 OR Race ILIKE '%none%'
                 OR Race IS NULL
                 OR TRIM(Race) = ''
            THEN 'Unknown'
            ELSE Race
        END AS Ethnicity_Group,

        CASE
            WHEN Age BETWEEN 0 AND 12 THEN 'Kids'
            WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
            WHEN Age BETWEEN 20 AND 34 THEN 'Young Adult'
            WHEN Age BETWEEN 35 AND 49 THEN 'Adult'
            WHEN Age BETWEEN 50 AND 64 THEN 'Middle-Aged'
            ELSE 'Senior'
        END AS Age_Groups,

        CASE
            WHEN Gender ILIKE '%none%'
                 OR Gender IS NULL
                 OR TRIM(Gender) = ''
            THEN 'Unknown'
            ELSE Gender
        END AS Gender_Group,

        

        CASE
            WHEN Email IS NOT NULL
                 OR TRIM(Email) <> ''
                 OR Email NOT ILIKE '%none%'
            THEN 1
            ELSE 0
        END AS Email_Flag,

        CASE
            WHEN `Social Media Handle` IS NOT NULL
                 or TRIM(`Social Media Handle`) <> ''
                 or `Social Media Handle` NOT ILIKE '%none%'
            THEN 1
            ELSE 0
        END AS SM_Flag

    FROM brighttvcasestudy.default.brighttvdatasetuserprofile
)

SELECT
    UserID,
    Age,
    Region,
    Ethnicity_Group,
    Age_Groups,
    Gender_Group,

    Email_Flag,
    SM_Flag
FROM cte1;

-----------------------------------------------------------
-----Viewership  table
----------------------------------------------
SELECT *
FROM brighttvcasestudy.default.viewership_dataset
LIMIT 10;
-----------------------------------------------
-----checking the size of the table and how many people are active users
-------------------------------------------------------------------------------

select COUNT (*) AS num_rows,
       COUNT(COALESCE(UserID0 ,userid4)) AS active_subs,
       COUNT(DISTINCT COALESCE(UserID0, userid4)) AS active_users
FROM brighttvcasestudy.default.viewership_dataset;

--------------------------------------------
-- channel2 checks
---------------------------
Select DISTINCT Channel2
from brighttvcasestudy.default.viewership_dataset;
-----------------------------------------------------------
---------standardizing duplicates or similar values  them into a single value 
---------------------------------------------------------------------
SELECT DISTINCT
    CASE
        WHEN UPPER(TRIM(Channel2)) = 'SAWSEE' THEN 'SawSee'
        WHEN UPPER(TRIM(Channel2)) IN (
            'SUPERSPORT LIVE EVENTS',
            'LIVE ON SUPERSPORT',
            'DSTV EVENTS 1'
        ) THEN 'Live Events'
        ELSE TRIM(Channel2)
    END AS TV_Channel
FROM brighttvcasestudy.default.viewership_dataset;
----------------------------------------------------------------------------------

----------------------------------------------------------------------------
  SELECT

        COALESCE(userid0, userid4, 0) AS userid,
DAYOFWEEK(TO_DATE(recorddate2)) AS day_of_week,
DATE_FORMAT(TO_DATE(recorddate2), 'MMMM') AS month_name,
        TO_DATE(recorddate2) AS watch_date,

        DATE_FORMAT(TO_DATE(recorddate2), 'yyyyMM') AS month_id,

        DAYNAME(TO_DATE(recorddate2)) AS day_name,

        CASE
            WHEN DAYNAME(TO_DATE(recorddate2)) IN ('Saturday','Sunday')
            THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_classification,

        DATE_FORMAT(recorddate2, 'HH:mm:ss') AS watch_time,

        HOUR(recorddate2) AS hour_of_day,

        CASE
            WHEN HOUR(recorddate2) BETWEEN 0 AND 5 THEN '01.Midnight'
            WHEN HOUR(recorddate2) BETWEEN 6 AND 11 THEN '02.Morning'
            WHEN HOUR(recorddate2) BETWEEN 12 AND 16 THEN '03.Afternoon'
            WHEN HOUR(recorddate2) BETWEEN 17 AND 23 THEN '04.Evening'
        END AS time_bucket,

        `Duration 2` AS duration,

       CASE
WHEN duration BETWEEN '00:05:00' and '0:30:00' THEN '01.LOW USAGE'
WHEN duration BETWEEN '00:30:01' and '0:59:59' THEN '02.MED USAGE'
WHEN duration > '00:59:59' THEN '03.HIGH USAGE:> 60 min'
WHEN duration <= '00:04:00' THEN 'no usage'
END AS SCREEN_TIME_BUCKET
FROM brighttvcasestudy.default.viewership_dataset;
---------------------------------------------------------------------------------------------------
----creating a table from cleaned data (Viewership table)
--------------------------------------------------------------------------------------------
cte2 AS (
    SELECT

        COALESCE(userid0, userid4, 0) AS userid,
DAYOFWEEK(TO_DATE(recorddate2)) AS day_of_week,
DATE_FORMAT(TO_DATE(recorddate2), 'MMMM') AS month_name,
        TO_DATE(recorddate2) AS watch_date,

        DATE_FORMAT(TO_DATE(recorddate2), 'yyyyMM') AS month_id,

        DAYNAME(TO_DATE(recorddate2)) AS day_name,

        CASE
    WHEN DAYNAME(TO_DATE(recorddate2, 'yyyy-MM-dd')) IN ('Sat', 'Sun')
    THEN 'Weekend'
    ELSE 'Weekday'
END AS day_classification,

        DATE_FORMAT(recorddate2, 'HH:mm:ss') AS watch_time,

        HOUR(recorddate2) AS hour_of_day,

       
     CASE
    WHEN HOUR(RecordDate2) BETWEEN 0 AND 5 THEN 'Midnight (00:00–05:59)'
    WHEN HOUR(RecordDate2) BETWEEN 6 AND 11 THEN 'Morning (06:00–11:59)'
    WHEN HOUR(RecordDate2) BETWEEN 12 AND 16 THEN 'Afternoon (12:00–16:59)'
    WHEN HOUR(RecordDate2) BETWEEN 17 AND 23 THEN 'Evening (17:00–23:59)'
END AS time_bucket,

        `Duration 2` AS duration,

        CASE
        WHEN duration IS NULL THEN 0
        ELSE (HOUR(duration) + MINUTE(duration) / 60.0 + SECOND(duration) / 3600.0)
    END AS Watch_Hours,
 CASE
        WHEN Duration IS NULL THEN 0
        ELSE (
            HOUR(Duration) * 60
            + MINUTE(Duration)
            + SECOND(Duration) / 60.0
        )
    END AS Watch_Minutes,

       CASE
WHEN duration BETWEEN '00:05:00' and '0:30:00' THEN '01.LOW USAGE'
WHEN duration BETWEEN '00:30:01' and '0:59:59' THEN '02.MED USAGE'
WHEN duration > '00:59:59' THEN '03.HIGH USAGE:> 60 min'
WHEN duration <= '00:04:00' THEN 'no usage'
END AS SCREEN_TIME_BUCKET,

        CASE
            WHEN UPPER(TRIM(Channel2)) = 'SAWSEE' THEN 'SawSee'
            WHEN UPPER(TRIM(Channel2)) IN (
                'SUPERSPORT LIVE EVENTS',
                'LIVE ON SUPERSPORT',
                'DSTV EVENTS 1'
            ) THEN 'Live Events'
            ELSE TRIM(Channel2)
        END AS TV_Channel

    FROM brighttvcasestudy.default.viewership_dataset
)

SELECT  Sub_ID,
       month_id,
       watch_date,
       day_of_week,
       day_name,
       watch_Minutes,
       day_classification,
       month_name

      FROM cte2;
------------------------------------------------------------------------------
---Combining the two table CTE1 AND CTE 2
----------------------------------------------
 WITH cte1 AS (
    SELECT
        UserID,
        Age,

        CASE
            WHEN Province ILIKE '%none%'
                 OR Province IS NULL
                 OR TRIM(Province) = ''
            THEN 'Uncategorized'
            ELSE Province
        END AS Region,

        CASE
            WHEN Race ILIKE '%other%'
                 OR Race ILIKE '%none%'
                 OR Race IS NULL
                 OR TRIM(Race) = ''
            THEN 'Unknown'
            ELSE Race
        END AS Ethnicity_Group,

        CASE
            WHEN Age BETWEEN 0 AND 12 THEN 'Kids'
            WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
            WHEN Age BETWEEN 20 AND 34 THEN 'Young Adult'
            WHEN Age BETWEEN 35 AND 49 THEN 'Adult'
            WHEN Age BETWEEN 50 AND 64 THEN 'Middle-Aged'
            ELSE 'Senior'
        END AS Age_Groups,

        CASE
            WHEN Gender ILIKE '%none%'
                 OR Gender IS NULL
                 OR TRIM(Gender) = ''
            THEN 'Unknown'
            ELSE Gender
        END AS Gender_Group,

        CASE
            WHEN Email IS NOT NULL
                 AND TRIM(Email) <> ''
                 AND Email NOT ILIKE '%none%'
            THEN 1
            ELSE 0
        END AS Email_Flag,

        CASE
            WHEN `Social Media Handle` IS NOT NULL
                 AND TRIM(`Social Media Handle`) <> ''
                 AND `Social Media Handle` NOT ILIKE '%none%'
            THEN 1
            ELSE 0
        END AS SM_Flag

    FROM brighttvcasestudy.default.brighttvdatasetuserprofile
),

cte2 AS (
    SELECT

        COALESCE(userid0, userid4, 0) AS userid,
DAYOFWEEK(TO_DATE(recorddate2)) AS day_of_week,
DATE_FORMAT(TO_DATE(recorddate2), 'MMMM') AS month_name,
        TO_DATE(recorddate2) AS watch_date,

        DATE_FORMAT(TO_DATE(recorddate2), 'yyyyMM') AS month_id,

        DAYNAME(TO_DATE(recorddate2)) AS day_name,

        CASE
    WHEN DAYNAME(TO_DATE(recorddate2, 'yyyy-MM-dd')) IN ('Sat', 'Sun')
    THEN 'Weekend'
    ELSE 'Weekday'
END AS day_classification,

        DATE_FORMAT(recorddate2, 'HH:mm:ss') AS watch_time,

        HOUR(recorddate2) AS hour_of_day,

       
     CASE
    WHEN HOUR(RecordDate2) BETWEEN 0 AND 5 THEN 'Midnight (00:00–05:59)'
    WHEN HOUR(RecordDate2) BETWEEN 6 AND 11 THEN 'Morning (06:00–11:59)'
    WHEN HOUR(RecordDate2) BETWEEN 12 AND 16 THEN 'Afternoon (12:00–16:59)'
    WHEN HOUR(RecordDate2) BETWEEN 17 AND 23 THEN 'Evening (17:00–23:59)'
END AS time_bucket,

        `Duration 2` AS duration,

        CASE
        WHEN duration IS NULL THEN 0
        ELSE (HOUR(duration) + MINUTE(duration) / 60.0 + SECOND(duration) / 3600.0)
    END AS Watch_Hours,
 CASE
        WHEN Duration IS NULL THEN 0
        ELSE (
            HOUR(Duration) * 60
            + MINUTE(Duration)
            + SECOND(Duration) / 60.0
        )
    END AS Watch_Minutes,

       CASE
WHEN duration BETWEEN '00:05:00' and '0:30:00' THEN '01.LOW USAGE'
WHEN duration BETWEEN '00:30:01' and '0:59:59' THEN '02.MED USAGE'
WHEN duration > '00:59:59' THEN '03.HIGH USAGE:> 60 min'
WHEN duration <= '00:04:00' THEN 'no usage'
END AS SCREEN_TIME_BUCKET,

--CASE
--WHEN duration ='00:00:00' THEN 'non user'
----else 'active user'
---end as user_flag,

        CASE
            WHEN UPPER(TRIM(Channel2)) = 'SAWSEE' THEN 'SawSee'
            WHEN UPPER(TRIM(Channel2)) IN (
                'SUPERSPORT LIVE EVENTS',
                'LIVE ON SUPERSPORT',
                'DSTV EVENTS 1'
            ) THEN 'Live Events'
            ELSE TRIM(Channel2)
        END AS TV_Channel

    FROM brighttvcasestudy.default.viewership_dataset
)

SELECT DISTINCT
       COALESCE(A.userid,B.userid) AS Sub_ID,
       Age,
       Region,
       Ethnicity_Group,
       Age_Groups,
    ---   gender,
       Gender_Group,
       Email_Flag,
       SM_Flag,
       month_id,
       watch_date,
       day_of_week,
       day_name,
       watch_Minutes,
       day_classification,
       month_name,
       tv_channel,
       watch_time,
       Watch_Hours,
       hour_of_day,
       duration,
       time_bucket
FROM cte2 A
LEFT JOIN cte1 B
    ON A.userid = B.userid;
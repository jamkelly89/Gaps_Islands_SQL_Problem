WITH C1 AS

-- let e = end ordinals, let s = start ordinals

(

  SELECT ID,  START_DATE AS ts, +1 AS type, NULL AS e,

    ROW_NUMBER() OVER(PARTITION BY ID ORDER BY START_DATE, id) AS s

  FROM ADMISSIONS

  WHERE OMIT_ADMISSION = 0

 

  UNION ALL

 

  SELECT ID, MEMBER_NBR,PROV_NPI

  , END_DATE  AS ts

  , -1 AS type,

    ROW_NUMBER() OVER(PARTITION BY ID ORDER BY END_DATE, id) AS e,

    NULL AS s

  FROM ADMISSIONS

  WHERE OMIT_ADMISSION = 0

 

),

C2 AS

-- let se = start or end ordinal, namely, how many events (start or end) happened so far

(

  SELECT C1.ID

  , C1.MEMBER_NBR

  , C1.PROV_NPI

  , C1.ts, C1.type

  , C1.s  ,C1.e

  , ROW_NUMBER() OVER(PARTITION BY C1.ID ORDER BY C1.ts, C1.type DESC, C1.id) AS se

  FROM C1

),

 

c9 AS (

SELECT C2.ID, C2.ts, C2.s, C2.e, C2.se

, C2.s - (C2.se - C2.s) - 1 AS ACTIVE_STARTS

, (C2.se - C2.e) - C2.e AS ACTIVES_AFTERS

, ts-1 AS prev_day

FROM  C2

),

 

 

C3 AS

-- For start events, the expression s - (se - s) - 1 represents how many sessions were active

-- just before the current (hence - 1)

--

-- For end events, the expression (se - e) - e represents how many sessions are active

-- right after this one

--

-- The above two expressions are 0 exactly when a group of packed intervals

-- either starts or ends, respectively

--

-- After filtering only events when a group of packed intervals either starts or ends,

-- group each pair of adjacent start/end events.

(

  SELECT C2.ID, C2.ts,

    FLOOR((ROW_NUMBER() OVER(PARTITION BY C2.ID ORDER BY C2.ts) - 1) / 2 + 1) AS grpnum

  FROM C2

  WHERE COALESCE(C2.s - (C2.se - C2.s) - 1, (C2.se - C2.e) - C2.e) = 0

),

 

--we need to group overlapping events, then handle adjacents

C4 as (

SELECT  C3.ID

,  MIN(C3.ts) AS STAY_START_DATE

, max(C3.ts) AS STAY_END_DATE

FROM C3

GROUP BY C3.ID, C3.grpnum

),

 

C5 as (

Select C4.ID, C4.STAY_START_DATE, C4.STAY_END_DATE

, LAG(C4.STAY_END_DATE) OVER(PARTITION BY C4.ID ORDER BY C4.STAY_START_DATE) AS PREV_END

FROM C4

),

 

 

--creates a sum that increases by 1 every time the previous end date is not equal to the current start date:

--this defines the groups of adjacent rows.

C6 AS (

Select C5.ID, C5.STAY_START_DATE, C5.STAY_END_DATE

, C5.PREV_END

, sum(CASE WHEN (C5.STAY_START_DATE -1) = C5.PREV_END then 0 else 1 END)

over( partition by C5.ID order by C5.STAY_START_DATE) AS grp

FROM C5

)

 

 

SELECT  C6.ID,  MIN(C6.STAY_START_DATE) AS STAY_START_DATE

, CASE WHEN max( C6.STAY_END_DATE ) > TRUNC(SYSDATE) THEN TO_DATE('12/31/9999','MM/DD/YYYY') ELSE max( C6.STAY_END_DATE ) END AS STAY_END_DATE

FROM C6

GROUP BY C6.ID, C6.grp

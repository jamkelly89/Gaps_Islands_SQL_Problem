# Union of Intervals / Gaps annd Islands Problem
This repository takes overlapping time intervals, combines them, and returns the longest continuous time interval in SQL. It can also merge adjacent intervals.

## Application
I was asked to reduce the runtime of SQL code that used cross joins to combine overlapping intervals and refresh a table. The code also merged adjacent intervals (as defined by adjacent days). These time intervals represented participant stays in a health care faciltiy. 

I was able to reduce the runtime from 2+ hours down to 20 seconds

## Research
There is a lot of information on the "Gaps & Islands problem" or "time interval union problem" with solutions in many languages. I enjoyed the one I found from Itzik the New 1: 17 seconds found [here](https://www.itprotoday.com/development-techniques-and-management/solutions-packing-date-and-time-intervals-puzzle). The solution references a problem called maximum concurrent sessions. The Itzik solution I pulled was not the fastest solution posted, but the one I enjoyed implementing for my application. 

It is really cool to treat the start and ends as discrete events. I found the replacing of joins with math to be pretty slick.

## Other resources on the problem 
- https://chaoxu.prof/posts/2019-04-27-union-of-intervals-in-sql.html
- https://medium.com/@asunadch/sql-gaps-islands-problem-from-leetcode-c47842154f27
- https://medium.com/analytics-vidhya/sql-classic-problem-identifying-gaps-and-islands-across-overlapping-date-ranges-5681b5fcdb8

/*
QUERY1:
We created a VIEW using MATCH_RECOGNIZE to capture the match for drop off followed by pickup within one hour
to calculate the total minutes between them which is the idle time

- First we created a view to capture the Idle Time for all the rides.
- We applied match recognize by partitioning using taxiId to have all the records of the same taxi, and then look for the pattern that starts with the flag isStart = false and followed by isStart = true
- We useed built-in functions to calculate the time difference between the ride start and end, and another function to find the area where the ride ends.
- finally we made a grouping by areaId to get the avearge for the idle time pr area within one hour
*/

CREATE VIEW Idle_time_view AS
SELECT * FROM Rides
MATCH_RECOGNIZE(
  PARTITION BY taxiId
  ORDER BY rideTime
  MEASURES
     END_RIDE.rideTime AS drop_off_Time,
     NEXT_RIDE.rideTime AS next_ride_start_time,
     TIMESTAMPDIFF(MINUTE, END_RIDE.rideTime, NEXT_RIDE.rideTime) AS idle_time,
     toAreaId(NEXT_RIDE.lat, NEXT_RIDE.lon) AS areaId,
     MATCH_ROWTIME() AS matchTime
  AFTER MATCH SKIP TO LAST NEXT_RIDE
  PATTERN (END_RIDE NEXT_RIDE)
  WITHIN INTERVAL '1' HOUR
  DEFINE
    END_RIDE AS END_RIDE.isStart = false,
    NEXT_RIDE AS NEXT_RIDE.isStart = true
);

/*
In this query we selected from the previous view the average ideal time by grouping by the areaId and a time window of 1 hour 
*/

SELECT  
        areaId, AVG(idle_time) AS avg_idle_time
FROM	Idle_time_view
GROUP BY
        areaId,	TUMBLE(matchTime, INTERVAL '1' hour);
/*

- First we created a view to capture the completed rides.
- We applied match recognize by partitioning using taxiId to have all the records of the same taxi, and then look for the pattern that starts 
  with the flag isStart = true which means the ride is started and followed by isStart = false which means the ride is ended with another condition the both are the same ride
- We useed built-in function to find the area where the ride ends.
- we create another view to calulate the average of payment by join the rides stream with fares stream
 - we created another view to get rides which have drop off in an area but without pickup withing 30 minuts
 - we created another view to count the empty taxi per area from the previous view
 - we make a join between two views, averagepayment and emptytaxicount to caluclate the profile per area
 
*/


-- the completed trips
CREATE VIEW CompletedRides AS
SELECT * FROM Rides 
MATCH_RECOGNIZE (
PARTITION BY taxiId
ORDER BY rideTime
MEASURES 
S.rideId as rideId,
toareaid(S.lon,S.lat) as areaId,
MATCH_ROWTIME() as rideEndTime
AFTER MATCH SKIP PAST LAST ROW
PATTERN (S E) 
DEFINE 
S AS S.isStart= true,
E AS E.isStart= false AND E.rideId = S.rideId
);


-- the average payment per area by join fares and rides streams
--and only the ayment which happend within the last 10 minuts for the rids
CREATE VIEW AveragePayment AS
select areaId, AVG(f.tip + f.fare) AS avgPayment
from
CompletedRides r,
Fares f
where
r.rideId = f.rideId AND
f.payTime BETWEEN r.rideEndTime - INTERVAL '10' MINUTE AND r.rideEndTime
GROUP BY
areaId,
TUMBLE(rideEndTime, INTERVAL '15' minute);


-- get the data for the rides which has dropoff in an area without pickup
-- the patten should be (END_RIDE NEXT_RIDE*) as per our undertanding to get 0 or more 
-- but unfortuantly it gives us error so we use this pattern and contnue solveing the peroblem
CREATE VIEW Idle_time_view AS
SELECT * FROM Rides
MATCH_RECOGNIZE(
  PARTITION BY taxiId
  ORDER BY rideTime
  MEASURES
     END_RIDE.rideTime AS drop_off_Time,
     toAreaId(END_RIDE.lon, END_RIDE.lat) AS areaId,
     MATCH_ROWTIME() AS matchTime,
	 COUNT(NEXT_RIDE.rideId) as rides_count
  AFTER MATCH SKIP PAST LAST ROW
  PATTERN (END_RIDE NEXT_RIDE+?)
  WITHIN INTERVAL '30' MINUTE
  DEFINE
    END_RIDE AS END_RIDE.isStart = false, NEXT_RIDE AS NEXT_RIDE.isStart = true
);


-- counting the empty taxi in the area
CREATE VIEW EmptyTaxiCount AS 
select areaId, COUNT(taxiId) AS empty_taxi_count from Idle_time_view 
WHERE rides_count =1
GROUP BY areaId

-- calculate the profit after joing the views of average payment and taxi empty
select A.areaId, (A.avgPayment/ E.empty_taxi_count) as profit_per_area  from EmptyTaxiCount AS E , AveragePayment AS A
WHERE E.areaId = A.areaId 
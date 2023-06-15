/*

- First we created a view to capture the completed ride within 30 minutes.
- We applied match recognize by partitioning using taxiId to have all the records of the same taxi, and then look for the pattern that starts 
  with the flag isStart = true which means the ride is started and followed by isStart = false which means the ride is ended with another condition the both are the same ride
- We useed built-in function to find the area where the ride ends.
- we created another view to calculate the count for all complted trips within 1 hour
- finally we tried to to rank the view and using the counts and order them to get the most top 10 as required
- but unfortunatlly there were some errors, but we can select from the view directly without errors. 

*/


CREATE VIEW CompletedRides AS
SELECT * FROM Rides 
MATCH_RECOGNIZE (
	PARTITION BY taxiId
	ORDER BY rideTime
	MEASURES 
		E.rideId as rideId,
		toareaid(S.lon,S.lat) as startAreaId,
		toareaid(E.lon,E.lat) as destinationAreaId,
		MATCH_ROWTIME() as matchTime
	AFTER MATCH SKIP PAST LAST ROW
	PATTERN (S E) 
	WITHIN INTERVAL '30' MINUTE
	DEFINE 
		S AS S.isStart= true,
		E AS E.isStart= false AND E.rideId = S.rideId
);


CREATE VIEW CompletedRidesCounts AS
SELECT * FROM CompletedRides 
MATCH_RECOGNIZE (
	PARTITION BY taxiId
	ORDER BY matchTime
	MEASURES 
		R.startAreaId as startAreaId,
		R.destinationAreaId as destinationAreaId,
		MATCH_ROWTIME() as matchTime,
		COUNT(rideId) AS ride_count_per_route
		AFTER MATCH SKIP PAST LAST ROW
	PATTERN (R+ E) 
	WITHIN INTERVAL '30' MINUTE
	DEFINE 
		E AS (E.startAreaId = R.startAreaId AND E.destinationAreaId = R.destinationAreaId)
);


-- this a selction form the view to validate that it works.
SELECT startAreaId, destinationAreaId , ride_count_per_route FROM CompletedRidesCounts; 

-- here is the ranking and ordring query but unfortunatly it doesn't work and there were some errors in the execution
SELECT * FROM (
	SELECT startAreaId, destinationAreaId , ride_count_per_route, ROW_NUMBER() OVER (PARTITION BY matchTime ORDER BY ride_count_per_route ASC ) as row_num
	FROM CompletedRidesCounts
)
WHERE row_num <=10
ORDER BY row_num DESC

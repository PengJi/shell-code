-- Q2
set lang aql;

SELECT 
	objID 
FROM 
	GalaxyLJ 
WHERE r < 22 and extinction_r > 0.175;

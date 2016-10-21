-- Q
-- count()
set lang aql;

SELECT 
	count(*) 
FROM 
	GalaxyLJ 
WHERE r < 22 and extinction_r > 0.175;

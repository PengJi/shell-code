-- Q
-- exchange the order of join
set lang aql;

SELECT 
	P.objID 
FROM 
	neighbors AS N join PhotoPrimaryLJ AS P on P.objID =N.NeighborObjID and P.objID = N.objID; 


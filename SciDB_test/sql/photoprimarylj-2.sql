-- Q11
set lang aql;

SELECT 
	P.objID 
FROM 
	PhotoPrimaryLJ AS P,neighbors AS N 
WHERE 
	P.objID = N.objID and P.objID =N.NeighborObjID;

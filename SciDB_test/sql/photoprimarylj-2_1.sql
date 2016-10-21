-- Q
-- join
set lang aql;

SELECT 
	P.objID 
FROM 
	PhotoPrimaryLJ AS P join neighbors AS N on P.objID =N.NeighborObjID
WHERE 
	P.objID = N.objID;

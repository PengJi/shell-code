-- Q
-- join
set lang aql;

Select 
	G.objID, G.u, G.g, G.r, G.i, G.z 
from 
	PhotoObjAll as G join StarLJ as S on G.parentID = S.parentID 
where
	G.parentID > 0;

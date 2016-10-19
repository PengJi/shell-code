-- Q
-- exchange the orde of join
set lang aql;

Select 
	G.objID, G.u, G.g, G.r, G.i, G.z 
from 
	StarLJ as S join PhotoObjAll as G on G.parentID = S.parentID 
where
	G.parentID > 0;

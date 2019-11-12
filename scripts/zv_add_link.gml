/// zv_add_link(point1, point2)
/*
    Links two verlets of given indices with constraint
*/

var _idx = ds_list_size(links);
var _p1 = verlets[| argument0], _p2 = verlets[| argument1];
var _p1pos = _p1[@ eVERLET.POS], _p2pos = _p2[@ eVERLET.POS];
ds_list_add(links, array_pack(argument0, argument1, point_distance(_p1pos[@ 0], _p1pos[@ 1], _p2pos[@ 0], _p2pos[@ 1])));
return _idx;

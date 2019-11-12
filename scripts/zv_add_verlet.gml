/// zv_add_verlet(x, y, vx, vy)
/*
    Adds verlet
*/

var _idx = ds_list_size(verlets);
ds_list_add(verlets, array_pack(array_pack(argument0, argument1), array_pack(argument0, argument1), array_pack(argument2, argument3)));
return _idx;

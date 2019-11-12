///zv_set_pos(point, x, y)
/*
    Sets position of given verlet point
*/
var _data = verlets[| argument0];
var _pos = _data[@ eVERLET.POS];
_pos[@ 0] = argument1;
_pos[@ 1] = argument2;

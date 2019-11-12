///zv_set_pos_prev(point, x, y)
/*
    Sets previous position of given verlet point
*/
var _data = verlets[| argument0];
_data[@ eVERLET.POS_PREV] = array_pack(argument1, argument2);

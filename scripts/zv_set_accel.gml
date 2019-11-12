///zv_set_accel(point, x, y)
/*
    Sets acceleration of given verlet point
*/
var _data = verlets[| argument0];
var _acc = _data[@ eVERLET.ACCEL];
_acc[@ 0] = argument1;
_acc[@ 1] = argument2;

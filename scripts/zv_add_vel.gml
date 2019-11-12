/// zv_add_vel(point, vx, vy)
/*
    Sets velocity of given verlet point
*/
var _data = verlets[| argument0];
var _vel = _data[@ eVERLET.VEL];
_vel[@ 0] += argument1;
_vel[@ 1] += argument2;

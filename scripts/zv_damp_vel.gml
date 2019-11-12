///zv_damp_vel(point, factor)
/*
    Adds dampening velocity of given verlet point
*/
var _data = verlets[| argument0];
var _vel = _data[@ eVERLET.VEL];

// calculate velocity
_vel[@ 0] -= _vel[@ 0] * argument1;
_vel[@ 1] -= _vel[@ 1] * argument1;

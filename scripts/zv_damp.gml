///zv_damp(point, factor)
/*
    Adds dampening acceleration of given verlet point
*/
var _data = verlets[| argument0];
var _posprev = _data[@ eVERLET.POS_PREV];
var _pos = _data[@ eVERLET.POS];
var _acc = _data[@ eVERLET.ACCEL];

var _velx = (_pos[@ 0] - _posprev[@ 0]);
var _vely = (_pos[@ 1] - _posprev[@ 1]);

_acc[@ 0] -= _velx * argument1;
_acc[@ 1] -= _vely * argument1;

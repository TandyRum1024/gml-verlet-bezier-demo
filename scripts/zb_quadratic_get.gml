#define zb_quadratic_get
/// zb_quadratic_get(p1, p2, p3, t)
/*
    Evaluates quadratic bezier curve from given points (p1, p2, p3) at given moment (t)
    returns 2D-position in array
*/
var _p1 = argument0, _p2 = argument1, _p3 = argument2, _t = argument3;

// calculate coefficients & pre-multiply
// OG formula : (1 - t) * (1 - t) * p1 + 2 * (1 - t) * t * p2 + t * t * p3
// by making a few variables that stores frequently used coefficients (like (1 - t) and t * t) we can simplify the formula
var _tsqr = _t * _t;
var _invt = 1.0 - _t;
var _invtsqr =  _invt * _invt;
_invt *= _t * 2;

// use the coefficients to calculate / interpolate the quadratic bezier curve's control points
var _x = _invtsqr * _p1[@ 0] + _invt * _p2[@ 0] + _tsqr * _p3[@ 0];
var _y = _invtsqr * _p1[@ 1] + _invt * _p2[@ 1] + _tsqr * _p3[@ 1];

// array_pack() is a function that returns an array that contains the given arguments for its elements
return array_pack(_x, _y);

#define zb_quadratic_get_deriv
/// zb_quadratic_get_deriv(p1, p2, p3, t)
/*
    Evaluates quadratic bezier curve's derivative from given points (p1, p2, p3) at given moment (t) &
    returns 2D-tangent in array
    Source formula from : https://en.wikipedia.org/wiki/B%C3%A9zier_curve
*/

// OG formula : 2 * (1 - t) * (p2 - p1) + 2 * t * (p3 - p2)
var _p1 = argument0, _p2 = argument1, _p3 = argument2, _t = argument3;
var _invt = (1.0 - _t) * 2.0;
_t *= 2.0;

var _x = _invt * (_p2[@ 0] - _p1[@ 0]) + _t * (_p3[@ 0] - _p2[@ 0]);
var _y = _invt * (_p2[@ 1] - _p1[@ 1]) + _t * (_p3[@ 1] - _p2[@ 1]);
return array_pack(_x, _y);

#define zb_draw_quadratic_spr
///zb_draw_quadratic_spr(p1, p2, p3, sprite, subimg, thickness, iteration, normalflip)
/*
    Draws sprite bent along the quadratic bezier curve via the use of primitive.
    p1, p2, p3 : the control points
    sprite, subimg : sprite and subimage to draw
    thickness : the "thickness" of drawn bezier curve sprite
    iteration : iterations to subdivide the curve.. high value means high quality and less performance
    normalflip : whether to flip the texture upside down or not (also flips normal)
*/
var _p1 = argument0, _p2 = argument1, _p3 = argument2;
var _p1x = _p1[@ 0], _p1y = _p1[@ 1];
var _p2x = _p2[@ 0], _p2y = _p2[@ 1];
var _p3x = _p3[@ 0], _p3y = _p3[@ 1];
var _sprite = argument3, _subimg = argument4, _thickness = argument5 * 0.5, _iteration = argument6, _inviter = 1 / (_iteration - 1), _normalflip = argument7;

if (_normalflip) _thickness *= -1;

// iterate & build primitive and draw
draw_primitive_begin_texture(pr_trianglestrip, sprite_get_texture(_sprite, _subimg));
for (var i=0; i<_iteration; i++)
{
    var _t = i * _inviter;
    
    // calculate position on the curve
    var _pos = zb_quadratic_get(_p1, _p2, _p3, _t);
    var _deriv = zb_quadratic_get_deriv(_p1, _p2, _p3, _t);
    var _derivmangitude = 1 / point_distance(0, 0, _deriv[@ 0], _deriv[@ 1]);
    var _nx = (_deriv[@ 1] * _derivmangitude) * _thickness, _ny = (-_deriv[@ 0] * _derivmangitude) * _thickness; // extrudes towards -V direction
    
    draw_vertex_texture(_pos[@ 0] + _nx, _pos[@ 1] + _ny, _t, 0); // --V
    draw_vertex_texture(_pos[@ 0] - _nx, _pos[@ 1] - _ny, _t, 1); // ++V
}
draw_primitive_end();


#define zb_draw_quadratic_spr_alt
///zb_draw_quadratic_spr_alt(p1, p2, p3, sprite, subimg, thickness, iteration, normalflip)
/*
    (alternative version that does not utilize zb_quadratic_get().. because why not)
    Draws sprite bent along the quadratic bezier curve via the use of primitive.
    p1, p2, p3 : the control points
    sprite, subimg : sprite and subimage to draw
    thickness : the "thickness" of drawn bezier curve sprite
    iteration : iterations to subdivide the curve.. high value means high quality and less performance
    normalflip : whether to flip the texture upside down or not (also flips normal)
*/
var _p1 = argument0, _p2 = argument1, _p3 = argument2;
var _p1x = _p1[@ 0], _p1y = _p1[@ 1];
var _p2x = _p2[@ 0], _p2y = _p2[@ 1];
var _p3x = _p3[@ 0], _p3y = _p3[@ 1];
var _p2subp1x = _p2x - _p1x, _p2subp1y = _p2y - _p1y;
var _p3subp2x = _p3x - _p2x, _p3subp2y = _p3y - _p2y;
var _sprite = argument3, _subimg = argument4, _thickness = argument5 * 0.5, _iteration = argument6, _inviter = 1 / (_iteration - 1), _normalflip = argument7;

if (_normalflip) _thickness *= -1;

// iterate & build primitive and draw
draw_primitive_begin_texture(pr_trianglestrip, sprite_get_texture(_sprite, _subimg));
for (var i=0; i<_iteration; i++)
{
    var _t = i * _inviter, _tsqr = _t * _t;
    var _invt = 1 - _t, _invtsqr = _invt * _invt;
    var _invt2 = _invt * 2, _t2 = _t * 2;
    var _midcoeff = _invt2 * _t;
    
    // calculate position on the curve
    var _posx = _invtsqr * _p1x + _midcoeff * _p2x + _tsqr * _p3x;
    var _posy = _invtsqr * _p1y + _midcoeff * _p2y + _tsqr * _p3y;
    
    // calculate derivative / tangent of the curve
    var _tangentx = _invt2 * _p2subp1x + _t2 * _p3subp2x;
    var _tangenty = _invt2 * _p2subp1y + _t2 * _p3subp2y;
    var _tangentmag = 1 / sqrt(_tangentx * _tangentx + _tangenty * _tangenty);
    var _nx = (_tangenty * _tangentmag) * _thickness, _ny = (-_tangentx * _tangentmag) * _thickness;
    
    draw_vertex_texture(_posx + _nx, _posy + _ny, _t, 0); // --V
    draw_vertex_texture(_posx - _nx, _posy - _ny, _t, 1); // ++V
}
draw_primitive_end();

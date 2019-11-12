#define zb_batch_begin
///zb_batch_begin()
// begins batching (aka start primitive drawing)
draw_primitive_begin_texture(pr_trianglestrip, 1);//sprite_get_texture(sprBody, 0));

#define zb_batch_end
///zb_batch_end()
// ends batching (aka end primitive drawing)
draw_primitive_end();

#define zb_batch_quadratic_spr_alt
///zb_batch_quadratic_spr_alt(p1, p2, p3, sprite, subimg, thickness, iteration, normalflip)
/*
    (Batched alternative version that does not utilize zb_quadratic_get().. because why not)
    Draws sprite bent along the quadratic bezier curve.
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

// fetch sprite UVs
var _spruv = sprite_get_uvs(_sprite, _subimg);
var _baseu = _spruv[@ 0];
var _deltau = _spruv[@ 2] - _baseu;
var _minv = _spruv[@ 1];
var _maxv = _spruv[@ 3];

// iterate & build primitive and draw
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
    var _tangentmag = (1 / sqrt(_tangentx * _tangentx + _tangenty * _tangenty)) * _thickness;
    var _nx = _tangenty * _tangentmag, _ny = -_tangentx * _tangentmag; // var _nx = (_tangenty * _tangentmag) * _thickness, _ny = (-_tangentx * _tangentmag) * _thickness;
    
    // calculate texture coords from fetched sprite UVs
    var _u = _baseu + _deltau * _t;
    
    // first & last vertex; make a degenerate triangle to prevent the triangle strip "leaking" to next instance of curve
    if (i == 0) draw_vertex_texture(_posx + _nx, _posy + _ny, _u, _minv);
    
    draw_vertex_texture(_posx + _nx, _posy + _ny, _u, _minv); // --V
    draw_vertex_texture(_posx - _nx, _posy - _ny, _u, _maxv); // ++V
    
    if (i == _iteration - 1) draw_vertex_texture(_posx - _nx, _posy - _ny, _u, _maxv);
}

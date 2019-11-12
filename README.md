# Simple verlet integration(ish) animated Bézier curve demo
![Preview footage of a silly humanoid figure being animated via physics simulation](PREVIEW.gif)

This demo utilizes quadratic bezier curve and (slightly modified) Verlet integration to simulate and render a silly-looking, Procedurally animated humanoid figure.<br>
The core principle is to simulate the physics of a 3 linked particles as a "limb" via integrators such as verlet integration or euler method, And using those 3 particles as control points for Quadratic Bézier curve.<br>
The principle would be pretty much the same even if you use different methods like RK4 or (velocity) Verlet and Euler method.

# Notable function (snippets)
Following function calculates / evaluates quadratic bezier curve and returns the position :
```
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
```
Following function returns the derivative of quadratic bezier curve and returns the resulting tangent :
```
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
```

Following routine is used to update the verlet integrator system :
```
/// Update all
// calculate delta time
var _secperstep = 1.0 / room_speed; // Desired : 1 / 60 seconds for each frame
var _step = min(((delta_time * 0.000001) / _secperstep), 4.0) * timeScale; // Quick fix : cap the delta time to prevent the simulation jerking out
var _steppow = _step * _step;

// integrate particles
for (var i=0; i<ds_list_size(verlets); i++)
{
    var _data = verlets[| i];
    var _posprev = _data[@ eVERLET.POS_PREV];
    var _pos = _data[@ eVERLET.POS];
    var _acc = _data[@ eVERLET.ACCEL];
    
    var _posx = _pos[@ 0];
    var _posy = _pos[@ 1];
    var _velx = (_posx - _posprev[@ 0]);
    var _vely = (_posy - _posprev[@ 1]);
    
    // Update previous position & accumulate velocities to current position
    _posprev[@ 0] = _posx;
    _posprev[@ 1] = _posy;
    _pos[@ 0] += _velx + _acc[@ 0] * _steppow;
    _pos[@ 1] += _vely + _acc[@ 1] * _steppow;
    
    _acc[@ 0] = 0;
    _acc[@ 1] = velGravity;
}

// update constraints
for (var k=0; k<linkIterations; k++)
{
    for (var i=0; i<ds_list_size(links); i++)
    {
        var _data = links[| i];
        
        // fetch both particles
        var _p1 = verlets[| _data[@ eLINK.P1]], _p2 = verlets[| _data[@ eLINK.P2]];
        var _p1pos = _p1[@ eVERLET.POS], _p2pos = _p2[@ eVERLET.POS];
        
        // calculate distance between both particle and use that to make two particle "closer" to each other
        // and apply appropirate force
        var _linkdist = _data[@ eLINK.DIST];
        var _pointdistx = _p1pos[@ 0] - _p2pos[@ 0], _pointdisty = _p1pos[@ 1] - _p2pos[@ 1];
        var _pointdist = sqrt(_pointdistx * _pointdistx + _pointdisty * _pointdisty);
        
        if (_pointdist > 0)
        {
            var _distdelta = (_linkdist - _pointdist) / _pointdist;
            var _movefactorx = _pointdistx * _distdelta * velLinkTensionFactor, _movefactory = _pointdisty * _distdelta * velLinkTensionFactor;

            _p1pos[@ 0] += _movefactorx; _p1pos[@ 1] += _movefactory;
            _p2pos[@ 0] -= _movefactorx; _p2pos[@ 1] -= _movefactory;
        }
    }
}
```

After simulating / integrating the particles, We can use those results as control points that is used to draw the bezier curve.
```
/// ARM R bezier limb
// zv_get_pos() returns the position of verlet particle of given index.
// in this case, we're fetching the positions of 3 particles that forms the right arm limb.
var _rarmpos1 = zv_get_pos(armRightRoot), _rarmpos2 = zv_get_pos(armRightJoint), _rarmpos3 = zv_get_pos(armRightLeaf);

// here, zb_batch_quadratic_spr_alt() draws deformed sprite along the Quadratic Bezier curve's surface
// with first 3 arguments defines the 3 control points of Quadratic bezier curve.
zb_batch_quadratic_spr_alt(_rarmpos1, _rarmpos2, _rarmpos3, sprLimb, 0, 6 * _modelscale, 8, false);
```

# Further reading & Materials that helped me
Verlet integration :<br>
[Wikipedia : Verlet integration](https://en.wikipedia.org/wiki/Verlet_integration)<br>
[Simulate Tearable Cloth and Ragdolls With Simple Verlet Integration](https://gamedevelopment.tutsplus.com/tutorials/simulate-tearable-cloth-and-ragdolls-with-simple-verlet-integration--gamedev-519)

Bézier curve :<br>
[A Primer on Bézier Curves](https://pomax.github.io/bezierinfo)<br>
[Wikipedia : Bézier curve](https://en.wikipedia.org/wiki/B%C3%A9zier_curve)<br>
[A thread on Stack Exchange about getting the derivatives of Quadratic Bézier curve that helped me to understand what kind of cryptic language the formula used for curve is](https://math.stackexchange.com/questions/885292/how-to-take-derivative-of-bezier-function)
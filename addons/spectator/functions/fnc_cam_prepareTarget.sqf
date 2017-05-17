
#include "script_component.hpp"
TRACE_1("Params",_this);

private _focus = vehicle (param [0, objNull, [objNull]]);

if !(isNull _focus) then {
    // Interpolate zoom
    private _zoom = [0, GVAR(camDistance)] select (GVAR(camMode) == MODE_FOLLOW);
    private _zoomTemp = GVAR(camDistanceTemp);

    if (_zoomTemp != _zoom) then {
        _zoomTemp = [_zoomTemp, _zoom, 10.0, GVAR(camDeltaTime)] call BIS_fnc_lerp;
        GVAR(camDistanceTemp) = _zoomTemp;
    };

    // The distance at which to place camera from the focus pivot
    private _bbd = [_focus] call BIS_fnc_getObjectBBD;
    private _distance = (_bbd select 1) + _zoomTemp;

    // The pivot on the target vehicle
    private _isMan = _focus isKindOf "Man";
    private _height = if !(_isMan) then { (_bbd select 2) / 3.0 } else { switch (stance _focus) do { case "STAND": {1.4}; case "CROUCH": {0.8}; default {0.4}; }; };

    private _center = if (_isMan) then { AGLToASL (_focus modelToWorldVisual (_focus selectionPosition "Spine3")) } else { AGLToASL (_focus modelToWorldVisual [0,0,_height]) };

    // Set dummy location and rotation
    private _dummy = GVAR(camDummy);

    _dummy setPosASL _center;
    [_dummy, [GVAR(camYaw), GVAR(camPitch), 0]] call BIS_fnc_setObjectRotation;

    // Apply location and rotation to camera
    GVAR(camera) setPosASL (AGLToASL (_dummy modelToWorldVisual [0, -_distance, 0]));
    GVAR(camera) setVectorDirAndUp [vectorDirVisual _dummy, vectorUpVisual _dummy];
};
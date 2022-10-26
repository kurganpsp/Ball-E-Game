
//----------------------------------------------------------------------------------------------
// Memory

const vec2 mTurnCount      = vec2(0.0,  0.0);
const vec2 mLevelCount     = vec2(0.0,  4.0);
const vec2 mMouse          = vec2(0.0,  8.0);
const vec2 mLevelCompleted = vec2(0.0,  9.0);
const vec2 mPlayedTurn     = vec2(1.0,  9.0);
const vec2 mReset          = vec2(2.0,  9.0);	// Reset a level (redraw buffer C and D)
const vec2 mLevel          = vec2(3.0,  9.0);
const vec2 mLevelTransi    = vec2(4.0,  9.0);
const vec2 mResolution     = vec2(5.0,  9.0);
const vec2 mActiveMasks    = vec2(0.0, 10.0);	// 1 to 8


const vec2 mDebug0         = vec2(0.0, 10.0);
const vec2 mDebug1         = vec2(1.0, 10.0);
const vec2 mDebug2         = vec2(2.0, 10.0);


//----------------------------------------------------------------------------------------------
// Defines and const

const vec3 gray   = vec3(0.5, 0.5, 0.5);

const vec3 black  = vec3(0.03, 0.03, 0.03);
const vec3 white  = vec3(0.90, 0.90, 0.90);
const vec3 red    = vec3(0.90, 0.05, 0.05);
const vec3 yellow = vec3(0.90, 0.90, 0.05);
const vec3 blue   = vec3(0.10, 0.10, 0.90);


const float hat      = 1.0;
const float belt     = 2.0;
const float strap    = 3.0;
const float stripesH = 4.0;
const float stripesV = 5.0;
const float smile    = 6.0;
const float pupils   = 7.0;
const float eyes     = 8.0;


#define PlayBallRadius 0.15
#define LevelTransiDur 2.25

#define Pi 3.14159265359


//----------------------------------------------------------------------------------------------
// Load/Store from IQ (https://www.shadertoy.com/view/MddGzf)

float isInside( vec2 p, vec2 c ) { vec2 d = abs(p-0.5-c) - 0.5; return -max(d.x,d.y); }


void Store(in vec2 re, in vec4 va, inout vec4 fragColor, in vec2 fragCoord)
{
    fragColor = ( isInside(fragCoord,re) > 0.0 ) ? va : fragColor;
}

void Store(in vec2 re, in bool va, inout vec4 fragColor, in vec2 fragCoord)
{
    fragColor = ( isInside(fragCoord,re) > 0.0 ) ? vec4(va) : fragColor;
}



//----------------------------------------------------------------------------------------------
// Masks

float Hat(vec2 uv)
{
    return step(0.5, uv.y);
}

float Strap(vec2 uv)
{
    float x = cos(2.0*Pi*uv.x-Pi/2.0)*cos(Pi*uv.y-Pi/2.0);
    return step(abs(x)-0.2, 0.0);
}

float Belt(vec2 uv)
{
    float y = sin(Pi*uv.y-Pi/2.0);
    return step(abs(y)-0.2, 0.0);
}

float Eyes(vec2 uv)
{
    float e;
    uv.x *= 2.0;    
    e  = step(length(uv-vec2(1.118,0.55))-0.098, 0.0);
    e += step(length(uv-vec2(0.88,0.55))-0.1, 0.0);
    return e;
}

float Pupils(vec2 uv)
{
    float e;
    uv.x *= 2.0;    
    e  = step(length(uv-vec2(1.08,0.55))-0.05, 0.0);
    e += step(length(uv-vec2(0.92,0.55))-0.05, 0.0);
    return e;
}

float SmileOld(vec2 uv)
{
    float e;
    uv.x *= 2.0;    
    e  = step(length(uv-vec2(1.00,0.50))-0.25, 0.0);
    e -= step(length(uv-vec2(1.00,0.85))-0.50, 0.0);
    
    return max(e, 0.0);
}

float Smile(vec2 uv)
{
    float e;
    uv.x *= 2.0;    
    e  = step(length(uv-vec2(1.00,0.50))-0.25, 0.0);
    e -= step(length(uv-vec2(1.00,0.50))-0.20, 0.0);
    e *= step(length(uv-vec2(1.00,0.08))-0.35, 0.0);
    return max(e, 0.0);
}


float StripesV(vec2 uv)
{
    float x = cos(2.0*Pi*uv.x-Pi/2.0)*cos(Pi*uv.y-Pi/2.0);
    x = fract(2.0*x-0.25);
    return step(abs(x)-0.5, 0.0);
}


float StripesH(vec2 uv)
{
    float y = sin(Pi*uv.y-Pi/2.0);
    y = fract(2.0*y-0.25);
    return step(abs(y)-0.5, 0.0);
}


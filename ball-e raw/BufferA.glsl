// Buffer A
// Inputs: Buffer A-n, Buffer B-l, ---, ---

#include "Common.glsl"

#iChannel0 "self"
#iChannel1 "file://BufferB.glsl"


//----------------------------------------------------------------------------------------------
// Load/Store from IQ (https://www.shadertoy.com/view/MddGzf)
vec4 Load(in vec2 re)
{
    return texture( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 );
}


//----------------------------------------------------------------------------------------------
bool IsLevelCompleted(in vec2 fragCoord)
{
    return length(texture(iChannel1, vec2(0.0))) <= 0.0001;

}


vec2 MaskBallCenter(in float maskId)
{
    maskId--;
    if(maskId < 5.0)
    {
        float a = 90.0*(maskId/4.0 - 0.5)*Pi/180.0;
        return 0.95*vec2(cos(a), sin(a));
    }
    else
    {
        float a = 38.0*((maskId-5.0)/2.0 - 0.5)*Pi/180.0;
        return 1.35*vec2(cos(a), sin(a));
    }
}


vec2 PaintBallCenter(in float id)
{
    float a = (180.0 + 90.0 * (id/4.0 - 0.5)) * Pi/180.0;
    return 0.95*vec2(cos(a), sin(a));
}


void ClickedMaskBall(in vec2 uv, in float maskId, inout vec4 clicked)
{
    uv -= MaskBallCenter(maskId);
    if(dot(uv, uv) < PlayBallRadius*PlayBallRadius)
    {
        clicked.a = maskId;
    }
}


void ClickedPaintBall(in vec2 uv, in float id, in vec3 color, inout vec4 clicked)
{
    uv -= PaintBallCenter(id);
    if(dot(uv, uv) < PlayBallRadius*PlayBallRadius)
    {
        clicked.rgb = color;
    }
}


vec4 ClickedBall(vec2 mouse)
{
    vec2 uvM = (2.0*mouse.xy - iResolution.xy) / iResolution.y;
    
    // Mask Balls:
    vec4 clicked = vec4(0.0);
    ClickedMaskBall(uvM, 1.0, clicked);
    ClickedMaskBall(uvM, 2.0, clicked);
    ClickedMaskBall(uvM, 3.0, clicked);
    ClickedMaskBall(uvM, 4.0, clicked);
    ClickedMaskBall(uvM, 5.0, clicked);
    ClickedMaskBall(uvM, 6.0, clicked);
    ClickedMaskBall(uvM, 7.0, clicked);
    ClickedMaskBall(uvM, 8.0, clicked);
    
    // Paint Balls:
    ClickedPaintBall(uvM, 0.0, blue,   clicked);
    ClickedPaintBall(uvM, 1.0, yellow, clicked);
    ClickedPaintBall(uvM, 2.0, red,    clicked);
    ClickedPaintBall(uvM, 3.0, black,  clicked);
    ClickedPaintBall(uvM, 4.0, white,  clicked);
    
    // Reset ball:
    vec2 uvc = uvM - vec2(-1.37, 0.0);
    if(dot(uvc, uvc) < PlayBallRadius*PlayBallRadius)
    {
        clicked = vec4(-1.0);
    }
    
    return clicked;
}


vec4 PlayTurn(in vec4 clicked, in float turn, inout vec4 fragColor, in vec2 fragCoord)
{
    
    vec4 playedTurn = vec4(0.0);
    
    if(clicked.a > 0.0)
    {
        // User clicked a mask ball.
        float maskId = clicked.a;

        // Get current state:
        float isUsed = Load(mActiveMasks + vec2(maskId)).r;
        
        // Toggle:
        maskId *= 1.0-2.0*isUsed;
        isUsed = abs(isUsed - 1.0);
        
        
        // Store mask on/off operation:
        Store(vec2(turn,0.0), vec4(0.0, 0.0, 0.0,  maskId), fragColor, fragCoord);
        playedTurn.a = maskId;
        
        // Store state:
        Store(mActiveMasks + vec2(abs(maskId)), vec4(isUsed), fragColor, fragCoord);
    }
    else if(clicked.r > 0.0)
    {
        // User clicked a paint ball.
        vec3 color = clicked.rgb;

        // Add color if different from previous one:
        if(color != Load(vec2(turn, 0.0)).rgb)
        {
            Store(vec2(turn,0.0), vec4(color,0.0), fragColor, fragCoord);
            playedTurn.rgb = color;
        }
    }
    
    return playedTurn;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Default:
    fragColor = texture(iChannel0, fragCoord/iResolution.xy);
    
    
    // Load state:
    float level          = Load(mLevel).r;
    float turnCount      = Load(mTurnCount).r;
    vec4  playedTurn     = vec4(0.0);
    vec4  mouse          = Load(mMouse);
    bool  reset          = (iFrame < 10);
    float levelTransi    = Load(mLevelTransi).r;
    bool  levelCompleted = Load(mLevelCompleted).r == 1.0;
    vec2  resolution     = Load(mResolution).xy;

     
    // Events:
    bool mouseClick = (mouse.z > 0.5) && (iMouse.z < 0.0);
    bool mouseWasDown = mouse.z > 0. || mouse.w > 0.;
    bool mouseIsUp = iMouse.z < 0. && iMouse.w < 0.;
    bool mouseUp = mouseWasDown && mouseIsUp;
    if(mouseUp)
    //if(mouseClick)
    {
        vec4 clicked = ClickedBall(mouse.zw);
        //vec4 clicked = ClickedBall(abs(mouse.zw));
        
        if(clicked.r == -1.0)
        {
            // User clicked the reset ball.
            reset = true;
            turnCount = 0.0;
        }
        else
        {
            // Play new turn:
            turnCount++;
            playedTurn = PlayTurn(clicked, turnCount, fragColor, fragCoord);
        }

    }
    
 
    
    // Level Completed?
    if((iTime > levelTransi) && (iFrame % 5 == 4) && (iFrame > 20))
    {
        levelCompleted = IsLevelCompleted(fragCoord);
        if(levelCompleted)
        {
            levelTransi = iTime + LevelTransiDur;
        }
    }

    
    // Level Transition:
    if(levelCompleted && (levelTransi - iTime < LevelTransiDur*4.0/10.0))
    {
        levelCompleted = false;
        level = (level != 24.0) ? level + 1.0 : 0.0;
        reset = true;
        turnCount = 0.0;
    }
    
    
    // Reset all on resolution change:
    if(resolution.xy != iResolution.xy)
    {
        levelCompleted = false;
        level = 0.0;
        reset = true;
        turnCount = 0.0;
        levelTransi = 0.0;
    }
    
    if(reset)
    {
        // Clear masks:
        Store(mActiveMasks + vec2(abs(1.0)), vec4(0.0), fragColor, fragCoord);
        Store(mActiveMasks + vec2(abs(2.0)), vec4(0.0), fragColor, fragCoord);
        Store(mActiveMasks + vec2(abs(3.0)), vec4(0.0), fragColor, fragCoord);
        Store(mActiveMasks + vec2(abs(4.0)), vec4(0.0), fragColor, fragCoord);
        Store(mActiveMasks + vec2(abs(5.0)), vec4(0.0), fragColor, fragCoord);
        Store(mActiveMasks + vec2(abs(6.0)), vec4(0.0), fragColor, fragCoord);
        Store(mActiveMasks + vec2(abs(7.0)), vec4(0.0), fragColor, fragCoord);
        Store(mActiveMasks + vec2(abs(8.0)), vec4(0.0), fragColor, fragCoord);
    }
    
    
    // Save State:
    Store( mLevel,          vec4(level),        fragColor, fragCoord);
    Store( mTurnCount,      vec4(turnCount),    fragColor, fragCoord);
    Store( mPlayedTurn,     playedTurn,         fragColor, fragCoord);
    Store( mLevelCompleted, levelCompleted,     fragColor, fragCoord);
    Store( mMouse,          iMouse,             fragColor, fragCoord);
    Store( mReset,          reset,              fragColor, fragCoord);
    Store( mLevelTransi,    vec4(levelTransi),  fragColor, fragCoord);
    Store( mResolution,     iResolution.xyxy,   fragColor, fragCoord);
}
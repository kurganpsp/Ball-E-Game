// Buffer D
// Inputs: Buffer A-n, Buffer D-l, ---, ---

#include "Common.glsl"

#iChannel0 "file://BufferA.glsl"
#iChannel1 "self"


#define IsBufferD


// Beyond this point, Buffer C and D use the exact same code.
//----------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------
// Load / Store (from IQ)
vec4 Load( in vec2 re )
{
    return texture( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 );
}


//----------------------------------------------------------------------------------------------
vec2 TextureCoord(in vec2 fragCoord)
{
    vec2 uv = vec2(fragCoord.y, 2.0*fragCoord.x - iResolution.x) / iResolution.yx;

    float distSq = dot(uv, uv);
    vec3 hit = vec3(uv.x, uv.y, sqrt(1.0 - min(1.0, distSq)));
    vec2 rs = vec2(atan(hit.x, hit.z), acos(-hit.y/1.0))/vec2(2.0*Pi,Pi) + vec2(0.5,0.0);
	return rs;    
}


#ifdef IsBufferC
//----------------------------------------------------------------------------------------------
// Draw solution:
#define ooooo color.rgb  = mix(white , color.rgb, min(color.a, 1.0));
#define ooooO color.rgb  = mix(black , color.rgb, min(color.a, 1.0));
#define oooOo color.rgb  = mix(red   , color.rgb, min(color.a, 1.0));
#define oooOO color.rgb  = mix(yellow, color.rgb, min(color.a, 1.0));
#define ooOoo color.rgb  = mix(blue  , color.rgb, min(color.a, 1.0));
#define ooOoO color.a   += Hat      (uv);
#define ooOOo color.a   += Belt     (uv);
#define ooOOO color.a   += Strap    (uv);
#define oOooo color.a   += StripesH (uv);
#define oOooO color.a   += StripesV (uv);
#define oOoOo color.a   += Smile    (uv);
#define oOoOO color.a   += Pupils   (uv);
#define oOOoo color.a   += Eyes     (uv);  
#define oOOoO color.a   -= Hat      (uv);
#define oOOOo color.a   -= Belt     (uv);
#define oOOOO color.a   -= Strap    (uv);
#define Ooooo color.a   -= StripesH (uv);
#define OoooO color.a   -= StripesV (uv);
#define OooOo color.a   -= Smile    (uv);
#define OooOO color.a   -= Pupils   (uv);
#define OoOoo color.a   -= Eyes     (uv);


vec4 Level0_14(in vec2 uv, in float level)
{
    vec4 color = vec4(white, 0.0);
    
    if(level == 0.0)
    {
        oOOoo ooOoo OoOoo
    }
    else if(level == 1.0)
    {
        ooooO oOoOO ooooo OooOO oOOoo oOoOo oooOo OooOo OoOoo
    }
    else if(level == 2.0)
    {
        oooOO ooOOO ooooO ooOoO oOOOO oooOo ooOOO ooOoo oOOOO oOOoO
    }
    else if(level == 3.0)
    {
        oooOO oOooO ooOoo oOooo OoooO ooOoo oOooO oooOO Ooooo OoooO
    }
    else if(level == 4.0)
    {
        ooooO ooOoO oOOoo ooOoo oOooO oooOO OoooO OoOoo oOOoO 
    }
    else if(level == 5.0)
    {
        ooooO oOoOO ooooo OooOO ooOoO ooOoo oOOoO oOOoo oooOO OoOoo
    }
    else if(level == 6.0)
    {
        oooOo oOooo oooOO ooOOo Ooooo oooOO oOooo oooOo Ooooo oOOOo
    }
    else if(level == 7.0)
    {
        oOooO oOooo ooOoo Ooooo OoooO ooOOO ooOoo oOOOO ooOOo ooOoo oOOOo
    }
    else if(level == 8.0)
    {
        ooooO oOoOo oOOoo ooOOo oooOO oOOOo ooOoO oooOO oOOoO OooOo OoOoo
    }
    else if(level == 9.0)
    {
        ooooO oOoOO oOoOo ooooo OooOO ooOOO ooOOo ooOoo oOOOO oOOOo oOOoo ooOoo OooOo OoOoo
    }
    if(level == 10.0)
    {
        ooooO oOooO oOooo oooOO OoooO Ooooo ooOOo ooOOO oooOO oOOOO oOOOo 
    }
    else if(level == 11.0)
    {
        oooOO ooOoO oooOo oOooO ooOoo OoooO oOooo oooOO ooOOo Ooooo oooOO oOOOo oOOoO
    }
    else if(level == 12.0)
    {
        ooOoo oOooO ooooo oOooo OoooO ooooo oOooO ooOoo OoooO ooooO oOooO oooOo OoooO Ooooo
    }
    else if(level == 13.0)
    {
        ooooO oOoOO ooooo oOOoo ooOoo OoOoo OooOO ooOoO oooOo oOOoO oOooo oooOo Ooooo oOOoo ooOoo OoOoo 
    }
    else if(level == 14.0)
    {
        ooOoo ooOOo ooOoo oOooO oOooo ooooo oOOOo Ooooo OoooO ooOoO ooooo oOooO oooOo OoooO oOOoO
    }
    
    return color;
}


vec4 Level15_24(in vec2 uv, in float level)
{
    vec4 color = vec4(white, 0.0);
    

    if(level == 15.0)
    {
        ooooO oOoOO ooooo oOOoo oooOo ooOOo ooOoO ooooO oOooO ooooo oOoOo OoooO oooOo oOOOo oOOoO OooOo OooOO OoOoo 
    }
    else if(level == 16.0)
    {
        ooooO oOoOo oOoOO ooooo OooOO oOOoo oooOO oOooO ooOoo OoooO ooOOo oooOO oOOOo ooOOO oooOO oOOOO OooOo OoOoo 
    }
    else if(level == 17.0)
    {
        ooooO oOoOo oOoOO ooooo oOooO oooOo OoooO oOooo oooOo oOooO ooooo OoooO Ooooo oOOoo oooOO OoOoo OooOO OooOo 
    }
    else if(level == 18.0)
    {
        oooOo oOooo ooOoo oOooO ooooo OoooO ooOOO ooooo oOOOO Ooooo ooOOo ooOoo oOooO ooooo OoooO ooOOO ooooo oOOOO oOOOo
    }
    else if(level == 19.0)
    {
        ooooO oOoOO oOoOo ooOOo ooooo oOOOo oOooo ooooo Ooooo ooOoO ooooo oOOoO oOOoo ooooO ooOOo ooOoo oOOOo oOooo ooOoo Ooooo ooOoO ooOoo ooOOo oooOO oOOoO oOOOo OooOo OooOO OoOoo 
    }
    else if(level == 20.0)
    {
        ooOoo oOooO oooOO OoooO oOooo oooOO oOooO ooOoo OoooO Ooooo ooOoO oooOO oOooO ooOoo OoooO oOooo ooOoo oOooO oooOO Ooooo OoooO ooOOo ooOoo oOooO oooOO OoooO oOooo oooOO oOooO ooOoo OoooO Ooooo oOOOo oOOoO 
    }
    else if(level == 21.0)
    {
        ooooO oOooO oOooo oooOo ooOOO oooOO oOOOO ooOOo ooOoo Ooooo OoooO ooOOO oooOo oOooO ooooo OoooO oOooo ooooo oOooO oooOo OoooO Ooooo ooOoO ooooo oOooO oooOo OoooO oOooo oooOo oOooO ooooo Ooooo OoooO oOOoO oOOOO oOOOo 
    }
    else if(level == 22.0)
    {
        oooOo oOooo ooOoo oOooO oooOO OoooO ooOOO oooOO oOOOO Ooooo ooOOo ooOoo oOooO oooOO OoooO ooOOO oooOO oOOOO oOOOo ooOoO ooOoo oOooO oooOo oOooo oooOO Ooooo ooOOo oooOO OoooO oOOOo ooOOO oooOo oOooo oooOO Ooooo ooOOo oooOO oOOOO oOOOo oOOoO 
    }
    else if(level == 23.0)
    {
        ooooO oOooO oooOo OoooO oOooo oooOO oOooO ooOoo OoooO Ooooo ooOOO oooOo oOooO ooooO OoooO oOooo ooOoo oOooO oooOO OoooO Ooooo ooOOo oooOO oOooO ooOoo OoooO oOooo ooooO oOooO oooOo Ooooo OoooO oOOOO oOOOo
    }
    else
    {
        ooooO oOooO ooooo OoooO ooOOO ooooo oOooO ooooO OoooO oOOOO oOoOo ooooO ooOOo ooOOO ooooo oOOOo oOOOO oOoOO ooooo ooOOo oOooo ooooO Ooooo oOOOo OooOO oOOoo ooOoo ooOOo oOooo ooooo oOooO ooOoo Ooooo ooOoO OoooO oooOO oOooO ooOoo OoooO ooOOO oooOo oOooO ooooo oOOOO oOOOo oOOoO OoooO OooOo OoOoo
    }

    return color;
}


void DrawSolution(inout vec4 fragColor, in vec2 fragCoord)
{
    if(Load(mReset).r == 1.0)
    {
        // Get level:
        float level = Load(mLevel).r;
        
        // Draw level:
        vec2 rs = TextureCoord(fragCoord);
        if(level < 15.0)
        {
	        fragColor = Level0_14(rs, level);
        }
        else
        {
	        fragColor = Level15_24(rs, level);
        }
    }
    else
    {
        vec2 uv = fragCoord / iResolution.xy;
        fragColor = texture(iChannel1, uv);
    }
}


#endif 


#ifdef IsBufferD
//----------------------------------------------------------------------------------------------
// Draw player turn:

vec4 AddLayer(in vec4 background, in vec2 rs, in vec4 opCode)
{
    // Initial color is background:
    vec4 color = background;
    
    if(opCode != vec4(0.0))
    {
        // Add turn:
        if(opCode.a == 0.0)
        {
            // Paint unmasked area:
            color.rgb = mix(opCode.rgb, color.rgb, min(color.a, 1.0));
        }
        else
        {
            // Combine current mask with new shape layer:
            float maskOp  = abs(opCode.a);
            float newMask = 1.0;
            
            if(      maskOp == 1.0 ) { newMask = Hat(rs);      }
            else if( maskOp == 2.0 ) { newMask = Belt(rs);     }
            else if( maskOp == 3.0 ) { newMask = Strap(rs);    }
            else if( maskOp == 4.0 ) { newMask = StripesH(rs); }
            else if( maskOp == 5.0 ) { newMask = StripesV(rs); }
            else if( maskOp == 6.0 ) { newMask = Smile(rs);    }
            else if( maskOp == 7.0 ) { newMask = Pupils(rs);   }
            else                     { newMask = Eyes(rs);     }
                  
            color.a += newMask*sign(opCode.a);
        }
    }
   
    return color;
}


void DrawTurn(inout vec4 fragColor, in vec2 fragCoord)
{
    if(Load(mReset).r == 1.0)
    {
        fragColor = vec4(white, 0.0);
    }
    else
    {
        // Get opcode:
        vec4 opcode = Load(mPlayedTurn);

        // Get backgound layer:
        vec2 uv = fragCoord/iResolution.xy;
        vec4 background = texture(iChannel1, uv);
            
        // Add layer:
        vec2 rs = TextureCoord(fragCoord);
        fragColor = AddLayer(background, rs, opcode);
    }
}


//----------------------------------------------------------------------------------------------
#endif


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
#ifdef IsBufferC
    DrawSolution(fragColor, fragCoord);
#else
    DrawTurn(fragColor, fragCoord);
    
#endif
}
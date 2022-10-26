#include "Common_p.glsl"

#iChannel0 "file://BufferA.glsl"

#iChannel1 "file://media/cubemaps/Forest_Blurred_{}.png" // Note the wildcard '{}'
#iChannel1::Type "CubeMap"

#iChannel2 "file://BufferC.glsl"
#iChannel3 "file://BufferD.glsl"


//----------------------------------------------------------------------------------------------
// Load/Store from IQ (https://www.shadertoy.com/view/MddGzf)
vec4 Load( in vec2 re )
{
    return texture( iChannel0, (0.5+re) / iChannelResolution[0].xy, -100.0 );
}


//----------------------------------------------------------------------------------------------
// Rendering
vec4 BallIntersect(in vec2 uv, in vec2 center, in float radius)
{
    uv -= center;
    float zSq = radius*radius - dot(uv, uv);
	return vec4(uv, sqrt(zSq), zSq) / radius;
}


vec4 BallTexture(vec3 hit, sampler2D sampler)
{
    vec2 uv = vec2((hit.y+1.0)/2.0, abs(hit.x));
    return texture(sampler, uv);
}


vec3 Shade(in vec3 hit, in vec3 hitR, in vec4 layer, in float levelTransi)
{
    // Light:
    vec3 light     = normalize(vec3(sin(iTime/10.0), 1.0, 1.5));
	
	// Geometry:
    vec3 rayDir    = vec3(0.0, 0.0, -1.0);
    vec3 backLight = normalize(-light * vec3(1.0, 1.0, 0.7));
    vec3 normal    = normalize(hit);
    vec3 reflected = reflect(rayDir, normal);

	// Model:    
    float ambient  = min(1.0, 0.43*normal.y+0.50);
    float diffuse  = max(0.0, dot(normal, light));
    float backward = max(0.0, dot(normal, backLight));
    float specular = max(0.0, dot(reflected, light));
    
	// Smooth diffuse a bit: 
    diffuse = pow(diffuse, 1.5);
    
    // Shade:
    vec3 color = vec3(0.0);
    if(layer.a == 0.0)
    {
        // Rubbery:
        color += 0.15 * ambient  * vec3(0.50,0.80,1.00);
        color += 0.99 * diffuse  * vec3(1.00,0.90,0.75);
        color += 0.15 * backward * vec3(0.25,0.25,0.25);

        color *= 0.99 * layer.rgb;
        color += 0.08 * pow(specular, 3.0);
        
        // Win:
        float t = min(1.0, 5.0*levelTransi);
    	float smt = smoothstep(0.0, 1.0, 1.0-abs(2.0*t-1.0));
        color *= 1.0 + 2.0*smt;
    }
    else
    {
        // Checker pattern:
        vec2 rs = vec2(atan(hitR.x, hitR.z), acos(-hitR.y))/vec2(2.0*Pi,Pi) + vec2(0.5,0.0);
        rs = floor(vec2(60.0, 30.0)*rs);
        float checker = mod(rs.x + mod(rs.y, 2.0), 2.0); 
        
        // "Fresnel" with color shift:
        vec3 Kr = pow(0.65 + 0.3*vec3(0.9, 1.0, 1.4)*vec3(1.0 + dot(normal, rayDir)), 1.1*vec3(1.5, 1.5, 1.8));
        Kr *= 0.97 + 0.03*checker;

        
        // Hack texture to get a skydome:
        vec3 tex = texture(iChannel1, reflected).rgb;
        vec3 sky = mix(vec3(0.90, 0.90, 1.0), 0.9*vec3(0.7, 0.80, 1.0), reflected.y);
        
        color  = 1.00 * Kr*mix(1.1*pow(1.0*tex, vec3(0.5)), sky, tex.r);
        color += 0.04 * diffuse * vec3(1.00);
        color += 0.56 * pow(specular, 8.0) * vec3(1.0, 0.92, 0.75) * (0.95 + 0.05*checker);
        
        color  = pow(color, vec3(4.0));
    }

    //color = texture(iChannel1, reflected).rgb;

    return color;
}


vec3 Shade(in vec3 hit, in vec4 layer, in float levelTransi)
{
    return Shade(hit, hit, layer, levelTransi);
}


float Shadow(in vec2 uv, in vec2 center, in float radius)
{
    uv -= center + 0.05*vec2(-sin(iTime/10.0), -1.0);
    radius = max(0.0, radius);
    float d = length(uv) - radius;
    
    return smoothstep(-0.12, 0.12, d); 
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


float Highlight(in vec2 uv, in float maskId)
{
    float isUsed = Load(mActiveMasks + vec2(maskId)).r;

    uv -= MaskBallCenter(maskId);
    float d = length(uv) - PlayBallRadius;
    
    return 0.9*isUsed*(1.0-smoothstep(-0.015, 0.03, d)); 
}


vec3 Scene(in vec2 uv, in vec3 back, in float levelTransi)
{
    vec3 color = back;

    // Animation:
    float t  = max(0.0, (levelTransi - 1.0/5.0)*5.0/4.0);
    float t0 = 2.0*t;
    float t1 = 2.0*(t-0.5);
    float smt = smoothstep(0.0, 1.0, 1.0-abs(2.0*t-1.0));
    float dy = t < 0.5 ? -pow(t0, 2.0) : pow(1.0-t1, 2.0);
    vec2  duv = vec2(-0.5*smt, 0.0);

    // Player ball:
    vec4 hitS = BallIntersect(uv, vec2(0.0, 2.0*dy), 0.7);
    if(hitS.w > 0.0)
    {
        vec3 hit = hitS.xyz;
        
        // Rotate:
        float a = 0.2*cos(1.0*iTime)+0.2;
        vec3 hitR = vec3(cos(a)*hit.x + sin(a)*hit.z, hit.y, -sin(a)*hit.x + cos(a)*hit.z);
        
        vec4 layer = BallTexture(hitR, iChannel3);
        color = Shade(hit, hitR, layer, levelTransi);
    }

    // Solution ball:
    hitS = BallIntersect(uv, vec2(-1.37, 0.60+smt), 0.3);
    if(hitS.w > 0.0)
    {
        vec3 hit = hitS.xyz;
        vec4 layer = BallTexture(hit, iChannel2);
        color = Shade(hit, layer, levelTransi);
    }


    return color;
}

vec3 Background(in vec2 uv, float levelTransi)
{
    // Animation:
    float t  = max(0.0, (levelTransi - 1.0/5.0)*5.0/4.0);
    float t0 = 2.0*t;
    float t1 = 2.0*(t-0.5);
    float smt = smoothstep(0.0, 1.0, 1.0-abs(2.0*t-1.0));
    float dy = t < 0.5 ? -pow(t0, 2.0) : pow(1.0-t1, 2.0);
    vec2  duv = vec2(-0.5*smt, 0.0);
   
    // Background:
    vec3 color;
    color = 0.6*vec3(0.4,0.6,0.7)*(1.0-0.4*length( uv ));
    
    // Adapted from: "wave greek frieze (165 chars)" by FabriceNeyret2
    vec2 suv = 8.0*(uv + 1.0);
    suv = fract(suv) - 0.5;
    float a = 12.0 * max(0.0, 1.0 - 2.0*length(suv));
    suv *= mat2(cos(a), -sin(a), sin(a), cos(a));
	color *= 0.88 + 0.12*smoothstep(-1.,1.,suv.y/fwidth(uv.y));

  
    // Shadows:
    color = pow(color, vec3(2.2));
    
    float shadow = 1.0;
    shadow *= Shadow(uv, vec2(0.0, 2.0*dy), 0.7);
    shadow *= Shadow(uv, vec2(-1.37, 0.60+smt), 0.3);
    shadow *= Shadow(uv-duv, vec2(-1.37, 0.0), PlayBallRadius);
     
    shadow *= Shadow(uv+duv, MaskBallCenter(1.0), PlayBallRadius);
    shadow *= Shadow(uv+duv, MaskBallCenter(2.0), PlayBallRadius);
    shadow *= Shadow(uv+duv, MaskBallCenter(3.0), PlayBallRadius);
    shadow *= Shadow(uv+duv, MaskBallCenter(4.0), PlayBallRadius);
    shadow *= Shadow(uv+duv, MaskBallCenter(5.0), PlayBallRadius);
    shadow *= Shadow(uv+duv, MaskBallCenter(6.0), PlayBallRadius);
    shadow *= Shadow(uv+duv, MaskBallCenter(7.0), PlayBallRadius);
    shadow *= Shadow(uv+duv, MaskBallCenter(8.0), PlayBallRadius);
    
    
    shadow *= Shadow(uv-duv, PaintBallCenter(0.0), PlayBallRadius);
    shadow *= Shadow(uv-duv, PaintBallCenter(1.0), PlayBallRadius);
    shadow *= Shadow(uv-duv, PaintBallCenter(2.0), PlayBallRadius);
    shadow *= Shadow(uv-duv, PaintBallCenter(3.0), PlayBallRadius);
    shadow *= Shadow(uv-duv, PaintBallCenter(4.0), PlayBallRadius);

    color *= shadow;

    // Highlights:
    const vec3 hl = vec3(0.95,0.5,0.05);
    color = mix(color, hl, Highlight(uv+duv, 1.0));
    color = mix(color, hl, Highlight(uv+duv, 2.0));
    color = mix(color, hl, Highlight(uv+duv, 3.0));
    color = mix(color, hl, Highlight(uv+duv, 4.0));
    color = mix(color, hl, Highlight(uv+duv, 5.0));
    color = mix(color, hl, Highlight(uv+duv, 6.0));
    color = mix(color, hl, Highlight(uv+duv, 7.0));
    color = mix(color, hl, Highlight(uv+duv, 8.0));
    
    return color;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    // Load state:
    float levelTransi  = Load(mLevelTransi).r;
    levelTransi = clamp(1.0-(levelTransi-iTime)/LevelTransiDur, 0.0, 1.0);

    
    // Render background:
    vec2 uvr = (2.0*fragCoord.xy - iResolution.xy) / iResolution.y;
    vec3 back = Background(uvr, levelTransi);

    // Render scene:
    float du = 2.0 / iResolution.y;
    const float aa = 1.0;

    vec3 color = vec3(0.00);
    for(float y=0.0; y<aa; y++)
    {
        for(float x=0.0; x<aa; x++)
        {
            vec2 uvaa = uvr + du*(0.5+vec2(x,y))/aa;
		    color += Scene(uvaa, back, levelTransi);
        }
    }
    
    color /= aa*aa;

    //Gamma correction
    color = pow(color, vec3(0.4545));

    fragColor = vec4(color, 0.0);
}
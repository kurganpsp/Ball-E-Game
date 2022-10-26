#define Pi 3.14159265359

#iChannel1 "file://media/cubemaps/Forest_Blurred_{}.png" // Note the wildcard '{}'
#iChannel1::Type "CubeMap"

#iChannel3 "file://media/horizon.jpg"

vec3 Background(in vec2 uv, float levelTransi)
{
    // Animacion:
    float t  = max(0.0, (levelTransi - 1.0/5.0)*5.0/4.0);
    float t0 = 2.0*t;
    float t1 = 2.0*(t-0.5);
    float smt = smoothstep(0.0, 1.0, 1.0-abs(2.0*t-1.0));
    float dy = t < 0.5 ? -pow(t0, 2.0) : pow(1.0-t1, 2.0);
    vec2  duv = vec2(-0.5*smt, 0.0);
   
    // Fondo:
    vec3 color;
    color = 0.7*vec3(0.4,0.6,0.7)*(1.0-0.1*length( uv ));
    
    // Adapted from: "wave greek frieze (165 chars)" by FabriceNeyret2
    vec2 suv = 8.0*(uv + 1.0);
    suv = fract(suv) - 0.5;
    float a = 12.0 * max(0.0, 1.0 - 2.0*length(suv));
    suv *= mat2(cos(a), sin(a), -sin(a), cos(a));
	color *= 0.88 + 0.12*smoothstep(-1.,1.,suv.y/fwidth(uv.y));
    
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy;
   
    // Renderizar fondo:
    vec2 uvr = (2.0*fragCoord.xy - iResolution.xy) / iResolution.y;
    vec3 back = Background(uvr, /*levelTransi*/1.0);
    
    fragColor = vec4(back, 0.0);
}
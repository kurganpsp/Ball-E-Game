#iChannel0 "file://media/cubemaps/uffizi_gallery_{}.jpg"
#iChannel0::Type "CubeMap"

#iChannel0::MinFilter "LinearMipMapLinear"
//#iChannel0::MagFilter "Nearest"
//#iChannel0::WrapMode "Clamp"

#define Pi 3.14159265359
#define RotX(a) mat3(1.,0.,0.,0.,cos(a),sin(a),0.,-sin(a),cos(a))
#define RotY(a) mat3(cos(a),0.,-sin(a),0.,1.,0.,sin(a),0.,cos(a))
#define RotZ(a) mat3(cos(a),sin(a),0.,-sin(a),cos(a),0.,0.,0.,1.)

float Smoothstep2(float t)
{
    return t*t*t*(10.0 + 6.0*t*t - 15.0*t);
}

float Smoothstep3(float t)
{
    float t2 = t*t;
    float t3 = t*t2;
    float t4 = t*t3;
    return t4*(35.0 - 20.0*t3 + 70.0*t2 - 84.0*t);
}


float Smoothstep4(float t)
{
    float t2 = t*t;
    float t3 = t*t2;
    float t4 = t*t3;
    float t5 = t*t4;
    return t5*(126.0 + 70.0*t4 - 315.0*t3 + 540.0*t2 - 420.0*t);
}



    
vec4 Sphere(vec2 uv, float eps)
{
    const float r = 0.8;

    
    float d = length(uv);
    float z = d < r ? sqrt(r*r - d*d) : 0.0;

    vec3 n = vec3(uv, z);
    n = normalize(n);
 
    float a = smoothstep(0., -eps, d - r);
    
    return vec4(n, a);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = 2.0*(fragCoord - 0.5*iResolution.xy)/iResolution.y;
    float eps = 1.0/iResolution.y;

    // Scene:
    vec4 na = Sphere(uv, 4.0*eps);
	float a = na.a;
    vec3 n0 = na.xyz;

    // Normal and reflection:
    vec3 r = reflect(vec3(0.0, 0.0, -1.0), n0);
    mat3 rot = RotY(-0.5)*RotX(-0.3);
    r = rot*r;
    n0 = rot*n0;
    
    // Shading:
    vec3 l = normalize(vec3(-1.5, 2.0, 1.0));
    
    float d = dot(n0,l);
    d = d*step(0.0,d);
    
    float s = dot(r,l);
    s = pow(s*step(0.0,s), 4.0);
    d = 0.4*d + 0.4*s;
    
    vec3 shd = 0.8*vec3(0.05+0.95*pow(d, 2.2));
    
	// Reflection:
  	float kr = 1.7*mix(1.0, pow(1.0 - na.z, 0.9), 0.5);
    vec3 rfl = kr*pow(texture(iChannel0, r, 4.0 ).xyz * vec3(0.95, 0.97, 1.0), vec3(1.2));
    
    
    float sum = 0.0;
    const float pass = 5.0;
    for(float i=0.0; i<pass; i++)
    {
        for(float j=0.0; j<pass; j++)
        {
            float t = 0.1*(iTime + (pass*i+j)/(60.0*pass*pass));
            vec2 uvs = uv + 4.0*eps*vec2(i, j)/pass;

            // Global rotation:
            mat3 rot3 = RotY(-2.0*t);
            vec3 n = rot3*rot*Sphere(uvs, eps).xyz;


            // Tweeners:
            t = 3.0*t;
            float t0 = 1.0-t*mod(floor(t), 2.0);
            float t1 = t*mod(floor(t+1.0), 2.0);
            t0 = Smoothstep2(fract(t0));    
            t1 = Smoothstep2(fract(t1));    

            // Segment rotations:
            float count = 11.0;
            vec3 nr = vec3(0);

            // X-Axis:
            nr.x = count*(1.1*(n.x + 1.0)/2.0 - 0.05);
            //float nxi = abs(floor(nr.x) - floor(count/2.0));
            //n = RotX(-2.0*Pi*t0*pow(nxi, 2.0)/4.0)*n;
            float nxi = floor(nr.x) - floor(count/2.0);
            n = RotX(-2.0*Pi*t0*sign(nxi)*pow(abs(nxi), 2.0)/4.0)*n;

            // Y-Axis:
            nr.y = count*(1.1*(n.y + 1.0)/2.0 - 0.05);
            float nyi = abs(floor(nr.y) - floor(count/2.0));
            n = RotY(-2.0*Pi*t1*pow(nyi, 2.0)/4.0)*n;
            //float nyi = floor(nr.y) - floor(count/2.0);
            //n = RotY(-2.0*Pi*t1*sign(nyi)*pow(abs(nyi), 2.0)/4.0)*n;

            // Pattern:
            nr.x = count*(1.1*(n.x + 1.0)/2.0 - 0.05);
            nr.z = count*(1.1*(n.z + 1.0)/2.0 - 0.05);

            vec3 th = 0.05*(1.0-0.7*abs(n));
            nr = smoothstep(0.85*th, th, 0.5-abs(fract(nr)-0.5));

            sum += nr.x*nr.y*nr.z;
        }
    }
    sum /= pass*pass;
    
    float bck = length(uv)-0.6;
    bck = 0.25*smoothstep(0.0, 0.4, bck) + 0.06*pow(length(uv), 2.0);
    vec3 color = mix(vec3(0.4*bck), mix(shd, rfl, sum), a);
    
	float rand = fract(sin((iTime + dot(fragCoord.xy, vec2(12.9898, 78.233))))* 43758.5453);
    color = (floor(255.0*color) + step(rand, fract(255.0*color)))/255.0;

    fragColor = vec4(color,1.0);
}
/*  6. Normal de superficie y objetos múltiples     */

#define PI 			3.1415926535

#define FLT_MAX 1e5
#define MAX_RECURSION 5

#define RAND_MAX 32767

#define LAMBERTIAN  0
#define METAL       1
#define DIELECTRIC  2

uint base_hash(uvec2 p) {
    p = 1103515245U*((p >> 1U)^(p.yx));
    uint h32 = 1103515245U*((p.x)^(p.y>>3U));
    return h32^(h32 >> 16);
}

float g_seed = 0.;

float hash1(inout float seed) {
    uint n = base_hash(floatBitsToUint(vec2(seed+=.1,seed+=.1)));
    return float(n)*(1.0/float(0xffffffffU));
}

/*  estructuras de datos */
struct ray {
    vec3 origin, direction;
};

struct material {
    int type;
    vec3 albedo;
    float fuzz;
};


struct hit_record{  // propiedades de superficie
    float t;
    vec3  p, normal;
    material mat_ptr;
};

struct hittable{        // solo una esfera por ahora
    vec3 center;
    float radius;
    material mat_ptr;

};

struct hittable_list{
    hittable lista[4];
    int list_size;
};

struct Camera{
    vec3 origin;
    vec3 lower_left_corner;
    vec3 horizontal;
    vec3 vertical;
};



// Funciones

// random number generator
float drand48(vec2 co) {
  return 2. * fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453) - 1.;
}

float squared_length(vec3 p){
    return p.x*p.x + p.y*p.y + p.z*p.z;
}

float schlick(float cosine, float ior) {
    float r0 = (1.-ior)/(1.+ior);
    r0 = r0*r0;
    return r0 + (1.-r0)*pow((1.-cosine),5.);
}

bool modified_refract(const in vec3 v, const in vec3 n, const in float ni_over_nt, 
                      out vec3 refracted) {
    float dt = dot(v, n);
    float discriminant = 1. - ni_over_nt*ni_over_nt*(1.-dt*dt);
    if (discriminant > 0.) {
        refracted = ni_over_nt*(v - n*dt) - n*sqrt(discriminant);
        return true;
    } else { 
        return false;
    }
}

// random direction in unit sphere (for lambert brdf)
vec3 random_in_unit_sphere(vec3 p){
    int n = 0;
    do {
        p = vec3(drand48(p.xy), drand48(p.zy), drand48(p.xz));
        n++;
    } while(squared_length(p) >= 1.0 && n < 3);
    return p;
}

vec3 reflect2(vec3 v, vec3 n){
    return v - 2.*dot(v,n)*n;
}

bool mat_scatter(const in ray r_in, const in hit_record rec, out vec3 attenuation, out ray scattered) 
{   
    if(rec.mat_ptr.type == LAMBERTIAN){
        
        vec3 rd = normalize(rec.normal + random_in_unit_sphere(rec.p));
        scattered = ray(rec.p, rd);
        attenuation = rec.mat_ptr.albedo;
        return true;
    
    }else if(rec.mat_ptr.type == METAL){
    
        vec3 reflected = reflect2(r_in.direction, rec.normal);
        scattered = ray(rec.p, normalize(reflected + rec.mat_ptr.fuzz * random_in_unit_sphere(rec.p)));
        attenuation = rec.mat_ptr.albedo;
        return true;
    
    }else if(rec.mat_ptr.type == DIELECTRIC){
        vec3 outward_normal, refracted, reflected = reflect2(r_in.direction, rec.normal);
        float ni_over_nt, reflect_prob, cosine;

        attenuation = vec3(1);
        if(dot(r_in.direction, rec.normal) > 0.){
            outward_normal = -rec.normal;
            ni_over_nt = rec.mat_ptr.fuzz;
            cosine = dot(r_in.direction, rec.normal);
            cosine = sqrt(1. - rec.mat_ptr.fuzz * rec.mat_ptr.fuzz * (1. - cosine * cosine));
        }else{
            outward_normal = rec.normal;
            ni_over_nt = 1. / rec.mat_ptr.fuzz;
            cosine = -dot(r_in.direction, rec.normal);
        }

        if(modified_refract(r_in.direction, outward_normal, ni_over_nt, refracted)){
            reflect_prob = schlick(cosine, rec.mat_ptr.fuzz);
        }else{
            reflect_prob = 1.;
        }

        if(hash1(g_seed) < reflect_prob){
            scattered = ray(rec.p, reflected);
        }else{
            scattered = ray(rec.p, refracted);
        }

        return true;
    }
    
    return false;
}


vec3 point_at_parameter(ray r, float t){
     return r.origin + t*r.direction;
}

bool hittable_hit(const in hittable sphere, const in ray r,const in float t_min, const in float t_max, inout hit_record rec){
    vec3 oc = r.origin - sphere.center;
    float a = dot(r.direction, r.direction);
    float b = dot(oc, r.direction);
    float c = dot(oc, oc) - (sphere.radius*sphere.radius);
    float discriminant = b*b - a*c;
    
    if (discriminant > 0.0) 
    {
        float temp = (-b - sqrt(discriminant))/a;
    
        if (temp < t_max && temp > t_min) 
        {
            rec.t = temp;
            rec.p = point_at_parameter(r, rec.t);
            rec.normal = (rec.p - sphere.center) / sphere.radius;
            rec.mat_ptr = sphere.mat_ptr;
            return true;
        }
        
        temp = (-b + sqrt(discriminant)) / a;
        
        if (temp < t_max && temp > t_min) 
        {
            rec.t = temp;
            rec.p = point_at_parameter(r, rec.t);
            rec.normal = (rec.p - sphere.center) / sphere.radius;
            rec.mat_ptr = sphere.mat_ptr;
            return true;
        }
    }
    return false;
}

// the scene
vec3 nSphere(vec3 pos) {
        return pos / length(pos);
}


ray get_ray(Camera cam, vec2 uv){
    cam.origin = vec3(0.0, 0.0, 0.0);
    cam.lower_left_corner = vec3(-2.0, -1.0, -1.0);
    cam.horizontal = vec3(4.0, 0.0, 0.0);
    cam.vertical = vec3(0.0, 2.0, 0.0);

    ray ray;
    ray.origin = cam.origin;
    ray.direction = cam.lower_left_corner + uv.x*cam.horizontal + uv.y*cam.vertical - cam.origin;
    
    return ray;
    
}


bool world_hit(const in hittable_list l, const in ray r, const in float t_min, const in float t_max,
                            inout hit_record rec){
    hit_record temp_rec;
    bool hit_anything = false;
    float closest_so_far = t_max;
    
    for (int i = 0; i < l.list_size; i++)
    {
        if (hittable_hit(l.lista[i], r, t_min, closest_so_far, temp_rec)) 
            {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec = temp_rec;
            }
        }
        return hit_anything;                                
}


/*
vec3 color(Ray r, hittable_list world){   
    Ray cur_ray = r;
    float cur_att = 1.0;
    
    for (int i = 0; i < 5; i++){   
        hit_record rec;
        if (world_hit(world, cur_ray, 0.001, FLT_MAX, rec)){ // búsqueda geométrica
            vec3 target = rec.p + rec.normal + random_in_unit_sphere(rec.p); // difuso + especular
            cur_att *= 0.5;
            cur_ray = Ray(rec.p, target - rec.p);
        }else{
            vec3 unit_direction = normalize(r.direction);
            float t = 0.5 * (unit_direction.y + 1.0);
            vec3 c = (1.0 - t) * vec3(1.0) + t * vec3(0.5, 0.7, 1.0);
            return cur_att * c;
        }
    }  
    return vec3(0);
}
*/


vec3 color(ray r, hittable_list world){   
    vec3 col = vec3(1);
    hit_record rec;
    
    //ray cur_ray = r;
    vec3 cur_att = vec3(1.0f);
    
    for (int i=0; i<MAX_RECURSION; i++){   
        if (world_hit(world, r, 0.001, FLT_MAX, rec)){ // búsqueda geométrica
            ray scattered;
            vec3 attenuation;
            if(mat_scatter(r, rec, attenuation, scattered)){
                col *= attenuation;
                r = scattered;
            }else{
                return vec3(0.0);
            }
        }else{
            float t = 0.5 * r.direction.y + 0.5;
            col *= mix(vec3(1), vec3(0.5, 0.7, 1.0), t);
            return col;
        }
    }  
    return vec3(0);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = fragCoord/iResolution.xy;
    float aspect = iResolution.y/iResolution.x;
    int ns = 1;

    vec3 lower_left_corner = vec3(-2.0, -1.0, -1.0);
    vec3 horizontal = vec3(4.0, 0.0, 0.0);
    vec3 vertical = vec3(0.0, 2.0, 0.0);
    vec3 origin = vec3(0.0, 0.0, 0.0);

    hittable lista[4];
    lista[0] = hittable(vec3(  0,      0, -1),   0.5, material(0, vec3(0.8,0.3,0.3), 0.0));
    lista[1] = hittable(vec3(  0, -100.5, -1), 100.0, material(0, vec3(0.8,0.8,0.0), 0.0));
    lista[2] = hittable(vec3(  1,      0, -1),   0.5, material(1, vec3(0.8,0.6,0.2), 1.0));
    lista[3] = hittable(vec3( -1,      0, -1),   0.5, material(1, vec3(0.8,0.8,0.8), 0.3));
    hittable_list world = hittable_list(lista,4);

    Camera cam;

    vec3 col = vec3(0,0,0);

    for(int s = 0 ; s<ns; s++)
    {
        float u = float(fragCoord.x + drand48(col.xy + float(s))) / iResolution.x;
        float v = float(fragCoord.y + drand48(col.xz + float(s))) / iResolution.y;

        ray r = get_ray(cam, vec2(u, v));
        col += color(r, world);
    }


    col /= float(ns);
    col = vec3( sqrt(col) );

    fragColor = vec4(col, 0);
}
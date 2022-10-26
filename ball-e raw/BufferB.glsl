// Buffer B
// Inputs: Buffer A-n, Buffer B-n, Buffer C-l, Buffer B-l

#include "Common.glsl"

#iChannel0 "file://BufferA.glsl"
#iChannel1 "self"
#iChannel2 "file://BufferC.glsl"
#iChannel3 "file://BufferD.glsl"


#define k 1.55


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
 	const vec2 count = vec2(40.0, 20.0);
    if((fragCoord.x < count.x) && (fragCoord.y < count.y))
    {
        int frame = iFrame % 5;
        if(frame == 0)
        {
            // Optimized non-uniform sampling:
            vec2 uv = fragCoord / count;

            float xf = 2.0*(uv.x - 0.5);
            uv.x = 0.5 + sign(xf)*(exp(k*abs(xf)) - 1.0) / (exp(k) - 1.0)/2.0;
            uv.y = (exp(k*uv.y) - 1.0) / (exp(k) - 1.0);
            uv.y = 0.05 + 0.92*uv.y;            

            // Store solution buffer:
            fragColor = texture(iChannel2, uv);
        }
        else if(frame == 1)
        {
            // Optimized non-uniform sampling:
            vec2 uv = fragCoord / count;

            float xf = 2.0*(uv.x - 0.5);
            uv.x = 0.5 + sign(xf)*(exp(k*abs(xf)) - 1.0) / (exp(k) - 1.0)/2.0;
            uv.y = (exp(k*uv.y) - 1.0) / (exp(k) - 1.0);
            uv.y = 0.05 + 0.92*uv.y;            

            // Store solution/play difference:  
            vec4 play     = texture(iChannel3, uv);
            vec4 solution = texture(iChannel1, fragCoord/iResolution.xy);
            fragColor = abs(play - solution);
        }
        else if(frame == 2)
        {
            vec4 sum = vec4(0.0);
            for(float i=0.0; i<count.x; i++)
            {
                sum += texture(iChannel1, vec2(i, fragCoord.y)/iResolution.xy);
            }
        	fragColor = sum;
        }
        else if(frame == 3)
        {
            vec4 sum = vec4(0.0);
            for(float i=0.0; i<count.y; i++)
            {
                sum += texture(iChannel1, vec2(fragCoord.y, i)/iResolution.xy);
            }
	        fragColor = sum;
        }
        else
        {
            discard;
        }
    }
 }

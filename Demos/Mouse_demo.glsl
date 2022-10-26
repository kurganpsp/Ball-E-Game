// Created by foodini - https://www.shadertoy.com/view/XlyBzt
// Adapted for VS Code Shadertoy

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 col = vec3(0.);

    //Draw a red cross where the mouse button was last down.
    //Dibuje una cruz roja donde se presionó el botón del mouse por última vez.
    if(abs(iMouse.x-fragCoord.x) < 4.) {
        col = vec3(1.,0.,0.);
    }
    if(abs(iMouse.y-fragCoord.y) < 4.) {
        col = vec3(1.,0.,0.);
    }
    
    //If the button is currently up, (iMouse.z, iMouse.w) is where the mouse was when the button last went down.
    //Si el botón está arriba, (iMouse.z, iMouse.w) es donde estaba el mouse la última vez que se presionó el botón.
    if(abs(iMouse.z-fragCoord.x) < 2.) {
        col = vec3(0.,0.,1.);
    }
    if(abs(iMouse.w-fragCoord.y) < 2.) {
        col = vec3(0.,0.,1.);
    }
    
    //If the button is currently down, (-iMouse.z, -iMouse.w) is where the button was when the click occurred.
    //Si el botón está actualmente presionado, (-iMouse.z, -iMouse.w) es donde estaba el botón cuando se produjo el clic.
    if(abs(-iMouse.z-fragCoord.x) < 2.) {
        col = vec3(0.,1.,0.);
    }
    if(abs(-iMouse.w-fragCoord.y) < 2.) {
        col = vec3(0.,1.,0.);
    }
    
    fragColor = vec4(col, 1.0);
}
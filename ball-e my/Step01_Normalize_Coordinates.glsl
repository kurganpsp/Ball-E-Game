/*
    // 16 chars - Píxeles cuadrados, coordenadas centradas en la parte inferior izquierda de la pantalla
        fragCoord /= iResolution.y ;

    // 17 chars - Píxeles estirados, coordenadas centradas en la parte inferior izquierda de la pantalla
        fragCoord /= iResolution.xy ;

    // 21 chars - Píxeles estirados, coordenadas centradas en la pantalla para los ejes X e Y
        fragCoord = fragCoord / iResolution.xy - .5 ;

    // 29 chars - Píxeles cuadrados, coordenadas centradas (supone una relación de pantalla de 16:9)
        fragCoord = fragCoord / iResolution.y - .5 ; fragCoord.x -= .4 ;

    // 33 chars - Píxeles cuadrados, coordenadas centradas en la pantalla para los ejes X e Y
        fragCoord = (fragCoord+fragCoord - (fragColor.xy=iResolution.xy) ) / fragColor.y ;

*/

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	// Píxeles cuadrados, coordenadas centradas en la pantalla para los ejes X e Y
    fragCoord = (fragCoord+fragCoord - (fragColor.xy=iResolution.xy) ) / fragColor.y ;

    // Renderizar escena:
    float f = smoothstep(.5,.6,length(fragCoord));
    
    vec3 color = vec3(f);
    
    fragColor = vec4(color, 1.0);
}


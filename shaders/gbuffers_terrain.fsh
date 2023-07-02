#version 150

in vec2 TexCoords;
in vec3 Normal;
in vec4 Color;

uniform sampler2D texture;

void main(){
    // Sample from texture atlas and account for biome color + ambien occlusion
   
    vec4 albedo = texture2D(texture, TexCoords) * Color;

    /* DRAWBUFFERS:01 */
    // Write the values to the color textures
   
    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    //gl_FragData[2] = albedo;//texture2D(texture, TexCoords) * vec4(0,0,1,0);
}
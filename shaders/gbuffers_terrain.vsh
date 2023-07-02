#version 150

uniform int worldTime;
attribute vec4 mc_Entity;
attribute vec3 vaPosition;
uniform vec3 chunkOffset;                       terrain chunk origin, used with attribute "vaPosition"
uniform vec3 cameraPosition;

out vec2 TexCoords;
out vec3 Normal;
out vec4 Color;

uniform mat4 modelViewMatrix;                   //model view matrix
uniform mat4 projectionMatrix;                  //projection matrix


//---------------------------------------------------------------------------------------------------------------------------------------
attribute vec3 position;
attribute vec3 normal;
attribute vec4 Ka; //TODO delete 
attribute vec4 Kd;
attribute vec4 Ks;
attribute vec2 texcoord;


out vec2 texCoord0;
out vec3 normal0;
out vec3 color0;
out vec3 position0;
// uniform mat4 Proj;
// uniform mat4 View;
// uniform mat4 Model;
uniform vec4 tranlasion;// check if i can delete

vec3 newnormal = vec3(0);
vec4 wave1 = vec4(1,0,0.5,10);// direction.x direction.y Steepness wave_length
vec4 wave2 = vec4(0,1,0.25,40);
vec4 wave3 = vec4(1,1,0.15,20);

vec4 wave4 = vec4(0.7489,0.6391,0.465,17);
vec4 wave5 = vec4(0.6306,0.5662,0.289,35);
vec4 wave6 = vec4(0.0663,0.8983,0.481,39);
vec4 wave7 = vec4(0.4848,0.2276,0.135,41);
vec4 wave8 = vec4(0.5347,0.0373,0.460,21);


//float Steepness = 0.5;  // var3
//float wave_length = 20;  //var4
float speed  = 1; // not used
//vec2 direction = normalize(vec2(0.5,0.5)); // var 1,2
#define M_PI 3.1415926535897932384626433832795
#define Earth_G 9.8
float ampControl = 0.5;
float flatenControl= 0.5;
float maxAmplitude = 0;
vec3 GerstnerWave(vec4 wave,vec3 pos,inout vec3 tangent,inout vec3 binormal)
{
	
	float steepness = wave.z;
	float wavelength = wave.w;
	float newX,newY,newZ;
	float k = 2*M_PI/wave.w;
	float Phase_speed = sqrt(Earth_G / k); // swap in Phase_speed instead of speed for earth like waves
	vec2 direction = normalize(wave.xy);
	
	float time = worldTime/50f;
	//float f = k * (dot(direction,(pos.xz+tranlasion.xz)) - Phase_speed * time);
	float f = k * (dot(direction,pos.xz) - Phase_speed * time);
	float amplitude = wave.z * ampControl/ k;
	maxAmplitude+= amplitude;

	// newX = pos.x + wave.x* amplitude * cos(f);
	// newY = pos.y + amplitude* sin(f);
	// newZ =  pos.z + wave.y * amplitude * cos(f);

//small optimize
	float COSF = cos(f);
	float SINF = sin(f);

	 tangent +=vec3(	-direction.x*direction.x * steepness * SINF
								,direction.x*steepness * COSF
								,-direction.x*direction.y*steepness*SINF );
	 binormal += vec3(	-direction.x*direction.y *steepness* SINF,
						direction.y* steepness * COSF,
						-direction.y*direction.y *steepness * SINF);

	//newnormal = normalize(cross(binormal,tangent));



	//vec3 newPos = vec3(newX,newY,newZ);
	return vec3(	direction.x* amplitude * COSF,
					amplitude* SINF,
					direction.y * amplitude * COSF);
}

 vec3 vert(vec3 pos)
 {
 		vec3 gridPoint = pos.xyz;
 		vec3 tangent = vec3(1, 0, 0);
 		vec3 binormal = vec3(0, 0, 1);
 		vec3 p = vec3(0); // p is the distorion
 		p += GerstnerWave(wave1, gridPoint, tangent, binormal);
 		p += GerstnerWave(wave2, gridPoint, tangent, binormal);
 		p += GerstnerWave(wave3, gridPoint, tangent, binormal);

		p += GerstnerWave(wave4, gridPoint, tangent, binormal);
		p += GerstnerWave(wave5, gridPoint, tangent, binormal);
		p += GerstnerWave(wave6, gridPoint, tangent, binormal);
		p += GerstnerWave(wave7, gridPoint, tangent, binormal);
		p += GerstnerWave(wave8, gridPoint, tangent, binormal);
 		vec3 normal = normalize(cross(binormal, tangent));
		newnormal = normal;
	
 	return p;
 }



void distosion(inout vec3 pos, inout vec3 normal,inout vec3 color)
{

	newnormal = vec3(0,1,0);//normal;

	vec3 position3 = vert(position);
	
	float maxY =position.y + maxAmplitude;
	float minY =position.y - maxAmplitude;
	float hight_bloom = 0.5 + (position3.y - minY)/(maxY-minY);
	position3 = vec3(position3.x,position3.y*flatenControl,position3.z);
	texCoord0 = texcoord;
	//color0 = vec3(Ka);
	//color0 =  (hight_bloom+ newnormal+vec3(1))/2*vec3(1,1,1);
	color0 = hight_bloom * vec3(1,1,1);

	// normal0 = (Model  * vec4(newnormal, 0.0)).xyz;
	// position0 = vec3(Proj *View *Model * vec4(position3, 1.0));
	// gl_Position = Proj *View * Model* vec4(position3, 1.0); //you must have gl_Position

}



//---------------------------------------------------------------------------------------------------------------------------------------
void main() {
    // Transform the vertex
    gl_Position = ftransform();
    // Assign values to varying variables
    TexCoords = gl_MultiTexCoord0.st;
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;



    if (mc_Entity.x == 12345.0/*WATER*/) {
	  	vec3 vertex_pos = vec3(vaPosition.x,0,vaPosition.z) + vec3(chunkOffset.x,0,chunkOffset.z) + vec3(cameraPosition.x,0,cameraPosition.z) ;
		float maxY =vertex_pos.y;
		float minY =vertex_pos.y;
		vertex_pos = vert(vertex_pos);
		maxY += maxAmplitude;
		minY -= maxAmplitude;
		float hight_bloom = 0.5 + (vertex_pos.y - minY)/(maxY-minY);

		gl_Position = gl_Position + projectionMatrix* modelViewMatrix * vec4(vertex_pos.x,vertex_pos.y*flatenControl,vertex_pos.z,0); //(vec4(0,vertex_pos.y,0,0));//vec4(vertex_pos.xyz,gl_Position.w);

		// Color = vec4((worldTime)/24000f + 0.7,0,0,1);
		// float test = mod(vaPosition.x,2);
		// if(test<=0.5){
		//  	gl_Position = gl_Position + vec4(0,1,0,0);
		//  	Color = vec4(0,worldTime,1,1);
		//  }
	}
    
}
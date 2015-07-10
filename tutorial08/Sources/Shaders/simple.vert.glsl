#ifdef GL_ES
precision highp float;
#endif

// Input vertex data, different for all executions of this shader
attribute vec3 pos;
attribute vec2 uv;
attribute vec3 nor;

// Output data: will be interpolated for each fragment
varying vec2 vUV;
varying vec3 positionWorldspace;
varying vec3 normalCameraspace;
varying vec3 eyeDirectionCameraspace;
varying vec3 lightDirectionCameraspace;

// Values that stay constant for the whole mesh
uniform mat4 MVP;
uniform mat4 V;
uniform mat4 M;
uniform vec3 lightPos;

void kore() {
	// Output position of the vertex, in clip space: MVP * position
	gl_Position = MVP * vec4(pos, 1.0);
	
	// Position of the vertex, in worldspace : M * position
	positionWorldspace = (M * vec4(pos, 1.0)).xyz;
	
	// Vector that goes from the vertex to the camera, in camera space.
	// In camera space, the camera is at the origin (0,0,0).
	vec3 vertexPositionCameraspace = (V * M * vec4(pos, 1.0)).xyz;
	eyeDirectionCameraspace = vec3(0.0, 0.0, 0.0) - vertexPositionCameraspace;

	// Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
	vec3 lightPositionCameraspace = (V * vec4(lightPos, 1.0)).xyz;
	lightDirectionCameraspace = lightPositionCameraspace + eyeDirectionCameraspace;
	
	// Normal of the the vertex, in camera space
	normalCameraspace = (V * M * vec4(nor, 0.0)).xyz; // Only correct if modelMatrix does not scale the model! Use its inverse transpose if not.
	
	// UV of the vertex. No special space for this one.
	vUV = uv;
}

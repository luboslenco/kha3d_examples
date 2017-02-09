#version 450

// Input vertex data, different for all executions of this shader
in vec3 pos;

void main() {
	// Just output position
	gl_Position = vec4(pos, 1.0);
}

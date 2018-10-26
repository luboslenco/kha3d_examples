#version 450

// Input vertex data, different for all executions of this shader
in vec3 pos;
in vec2 uv;

// Output data: will be interpolated for each fragment.
out vec2 vUV;

// Values that stay constant for the whole mesh
uniform mat4 MVP;

void main() {
	// Output position of the vertex, in clip space: MVP * position
	gl_Position = MVP * vec4(pos, 1.0);

	// UV of the vertex. No special space for this one.
	vUV = uv;
}

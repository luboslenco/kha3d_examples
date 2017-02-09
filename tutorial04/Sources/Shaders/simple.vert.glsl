#version 450

// Input vertex data, different for all executions of this shader
in vec3 pos;
in vec3 col;

// Output data - will be interpolated for each fragment.
out vec3 fragmentColor;

// Values that stay constant for the whole mesh
uniform mat4 MVP;

void main() {
	// Output position of the vertex, in clip space: MVP * position
	gl_Position = MVP * vec4(pos, 1.0);

	// The color of each vertex will be interpolated
	// to produce the color of each fragment
	fragmentColor = col;
}

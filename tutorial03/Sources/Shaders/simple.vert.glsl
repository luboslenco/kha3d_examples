// Input vertex data, different for all executions of this shader
attribute vec3 pos;

// Values that stay constant for the whole mesh
uniform mat4 MVP;

void kore() {
	// Output position of the vertex, in clip space : MVP * position
	gl_Position = MVP * vec4(pos, 1.0);
}

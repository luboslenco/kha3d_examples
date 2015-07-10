#ifdef GL_ES
precision highp float;
#endif

// Input vertex data, different for all executions of this shader
attribute vec3 pos;
attribute vec3 col;

// Output data - will be interpolated for each fragment.
varying vec3 fragmentColor;

// Values that stay constant for the whole mesh
uniform mat4 MVP;

void kore() {
	// Output position of the vertex, in clip space: MVP * position
	gl_Position = MVP * vec4(pos, 1.0);

	// The color of each vertex will be interpolated
	// to produce the color of each fragment
	fragmentColor = col;
}

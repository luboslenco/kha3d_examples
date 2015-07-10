#ifdef GL_ES
precision mediump float;
#endif

// Interpolated values from the vertex shaders
varying vec3 fragmentColor;

void kore() {
	// Output color = color specified in the vertex shader,
	// interpolated between all 3 surrounding vertices
	gl_FragColor = vec4(fragmentColor, 1.0);
}

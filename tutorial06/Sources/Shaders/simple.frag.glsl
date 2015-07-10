#ifdef GL_ES
precision mediump float;
#endif

// Interpolated values from the vertex shaders
varying vec2 vUV;

// Values that stay constant for the whole mesh.
uniform sampler2D myTextureSampler;

void kore() {

	// Output color = color of the texture at the specified UV
	gl_FragColor = texture2D(myTextureSampler, vUV);
}

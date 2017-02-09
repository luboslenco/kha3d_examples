#version 450

// Interpolated values from the vertex shaders
in vec2 vUV;

// Values that stay constant for the whole mesh.
uniform sampler2D myTextureSampler;

out vec4 fragColor;

void main() {

	// Output color = color of the texture at the specified UV
	fragColor = texture(myTextureSampler, vUV);
}

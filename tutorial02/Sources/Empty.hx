package;

import kha.Framebuffer;
import kha.Color;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;

class Empty {

	// An array of 3 vectors representing 3 vertices to form a triangle
	static var vertices:Array<Float> = [
	   -1.0, -1.0, 0.0, // Bottom-left
	    1.0, -1.0, 0.0, // Bottom-right
	    0.0,  1.0, 0.0  // Top
	];
	// Indices for our triangle, these will point to vertices above
	static var indices:Array<Int> = [
		0, // Bottom-left
		1, // Bottom-right
		2  // Top
	];

	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var pipeline:PipelineState;

	public function new() {
		// Define vertex structure
		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
        // Save length - we only store position in vertices for now
        // Eventually there will be texture coords, normals,...
        var structureLength = 3;

		// Compile pipeline state
		// Shaders are located in 'Sources/Shaders' directory
        // and Kha includes them automatically
		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.fragmentShader = Shaders.simple_frag;
		pipeline.vertexShader = Shaders.simple_vert;
		pipeline.colorAttachmentCount = 1;
		pipeline.colorAttachments[0] = kha.graphics4.TextureFormat.RGBA32;
		pipeline.depthStencilAttachment = kha.graphics4.DepthStencilFormat.Depth16;
		pipeline.compile();

		// Create vertex buffer
		vertexBuffer = new VertexBuffer(
			Std.int(vertices.length / 3), // Vertex count - 3 floats per vertex
			structure, // Vertex structure
			Usage.StaticUsage // Vertex data will stay the same
		);

		// Copy vertices to vertex buffer
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData.set(i, vertices[i]);
		}
		vertexBuffer.unlock();

		// Create index buffer
		indexBuffer = new IndexBuffer(
			indices.length, // 3 indices for our triangle
			Usage.StaticUsage // Index data will stay the same
		);

		// Copy indices to index buffer
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = indices[i];
		}
		indexBuffer.unlock();
    }

	public function render(frames:Array<Framebuffer>) {
		// A graphics object which lets us perform 3D operations
		var g = frames[0].g4;

		// Begin rendering
        g.begin();

        // Clear screen to black
		g.clear(Color.Black);

		// Bind state we want to draw with
		g.setPipeline(pipeline);

		// Bind data we want to draw
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		// Draw!
		g.drawIndexedVertices();

		// End rendering
		g.end();
    }
}

package;

import kha.Game;
import kha.Framebuffer;
import kha.Color;
import kha.Loader;
import kha.graphics4.Program;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;

class Empty extends Game {

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
	var program:Program;

	public function new() {
		super("Empty", false);
	}

	override public function init() {
		// Define vertex structure
		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
        // Save length - we only store position in vertices for now
        // Eventually there will be texture coords, normals,...
        var structureLength = 3;

        // Load shaders - these are located in 'Sources/Shaders' directory
        // and Kha includes them automatically
		var fragmentShader = new FragmentShader(Loader.the.getShader("simple.frag"));
		var vertexShader = new VertexShader(Loader.the.getShader("simple.vert"));
	
		// Link program with fragment and vertex shaders we loaded
		program = new Program();
		program.setFragmentShader(fragmentShader);
		program.setVertexShader(vertexShader);
		program.link(structure);

		// Create vertex buffer
		vertexBuffer = new VertexBuffer(
			Std.int(vertices.length / structureLength), // Vertex count - 9 / 3 = 3
			structure, // Vertex structure
			Usage.StaticUsage // Vertex data will stay the same
		);
		
		// Copy vertices to vertex buffer
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData[i] = vertices[i];
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

	override public function render(frame:Framebuffer) {
		// A graphics object which lets us perform 3D operations
		var g = frame.g4;

		// Begin rendering
        g.begin();

        // Clear screen to black
		g.clear(Color.Black);

		// Bind shader program we want to draw with
		g.setProgram(program);

		// Bind data we want to draw
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		// Draw!
		g.drawIndexedVertices();

		// End rendering
		g.end();
    }
}

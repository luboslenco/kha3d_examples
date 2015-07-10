package ;

import kha.Game;
import kha.Framebuffer;
import kha.Color;
import kha.Loader;
import kha.LoadingScreen;
import kha.Configuration;
import kha.Image;
import kha.graphics4.TextureUnit;
import kha.graphics4.Program;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
import kha.math.Matrix4;
import kha.math.Vector3;

class Empty extends Game {

	// An array of vertices to form a cube
	static var vertices:Array<Float> = [
	    -1.0,-1.0,-1.0,
		-1.0,-1.0, 1.0,
		-1.0, 1.0, 1.0,
		 1.0, 1.0,-1.0,
		-1.0,-1.0,-1.0,
		-1.0, 1.0,-1.0,
		 1.0,-1.0, 1.0,
		-1.0,-1.0,-1.0,
		 1.0,-1.0,-1.0,
		 1.0, 1.0,-1.0,
		 1.0,-1.0,-1.0,
		-1.0,-1.0,-1.0,
		-1.0,-1.0,-1.0,
		-1.0, 1.0, 1.0,
		-1.0, 1.0,-1.0,
		 1.0,-1.0, 1.0,
		-1.0,-1.0, 1.0,
		-1.0,-1.0,-1.0,
		-1.0, 1.0, 1.0,
		-1.0,-1.0, 1.0,
		 1.0,-1.0, 1.0,
		 1.0, 1.0, 1.0,
		 1.0,-1.0,-1.0,
		 1.0, 1.0,-1.0,
		 1.0,-1.0,-1.0,
		 1.0, 1.0, 1.0,
		 1.0,-1.0, 1.0,
		 1.0, 1.0, 1.0,
		 1.0, 1.0,-1.0,
		-1.0, 1.0,-1.0,
		 1.0, 1.0, 1.0,
		-1.0, 1.0,-1.0,
		-1.0, 1.0, 1.0,
		 1.0, 1.0, 1.0,
		-1.0, 1.0, 1.0,
		 1.0,-1.0, 1.0
	];
	// Array of texture coords for each cube vertex
	static var uvs:Array<Float> = [
	    0.000059, 0.000004, 
		0.000103, 0.336048, 
		0.335973, 0.335903, 
		1.000023, 0.000013, 
		0.667979, 0.335851, 
		0.999958, 0.336064, 
		0.667979, 0.335851, 
		0.336024, 0.671877, 
		0.667969, 0.671889, 
		1.000023, 0.000013, 
		0.668104, 0.000013, 
		0.667979, 0.335851, 
		0.000059, 0.000004, 
		0.335973, 0.335903, 
		0.336098, 0.000071, 
		0.667979, 0.335851, 
		0.335973, 0.335903, 
		0.336024, 0.671877, 
		1.000004, 0.671847, 
		0.999958, 0.336064, 
		0.667979, 0.335851, 
		0.668104, 0.000013, 
		0.335973, 0.335903, 
		0.667979, 0.335851, 
		0.335973, 0.335903,
		0.668104, 0.000013, 
		0.336098, 0.000071, 
		0.000103, 0.336048, 
		0.000004, 0.671870, 
		0.336024, 0.671877, 
		0.000103, 0.336048, 
		0.336024, 0.671877, 
		0.335973, 0.335903, 
		0.667969, 0.671889, 
		1.000004, 0.671847, 
		0.667979, 0.335851
	];

	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var program:Program;

	var mvp:Matrix4;
	var mvpID:ConstantLocation;

	var textureID:TextureUnit;
    var image:Image;

	public function new() {
		super("Empty");
	}

	override public function init() {
        Configuration.setScreen(new LoadingScreen());

        // Load room with our texture
        Loader.the.loadRoom("room0", loadingFinished);
    }

	function loadingFinished() {
		// Define vertex structure
		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
        structure.add("uv", VertexData.Float2);
        // Save length - we store position and uv data
        var structureLength = 5;

        // Load shaders - these are located in 'Sources/Shaders' directory
        // and Kha includes them automatically
		var fragmentShader = new FragmentShader(Loader.the.getShader("simple.frag"));
		var vertexShader = new VertexShader(Loader.the.getShader("simple.vert"));
	
		// Link program with fragment and vertex shaders we loaded
		program = new Program();
		program.setFragmentShader(fragmentShader);
		program.setVertexShader(vertexShader);
		program.link(structure);

		// Get a handle for our "MVP" uniform
		mvpID = program.getConstantLocation("MVP");

		// Get a handle for texture sample
		textureID = program.getTextureUnit("myTextureSampler");

		// Texture
		image = Loader.the.getImage("uvtemplate");

		// Projection matrix: 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
		var projection = Matrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		// Or, for an ortho camera
		//var projection = Matrix4.orthogonalProjection(-10.0, 10.0, -10.0, 10.0, 0.0, 100.0); // In world coordinates
		
		// Camera matrix
		var view = Matrix4.lookAt(new Vector3(4, 3, 3), // Camera is at (4, 3, 3), in World Space
								  new Vector3(0, 0, 0), // and looks at the origin
								  new Vector3(0, 1, 0) // Head is up (set to (0, -1, 0) to look upside-down)
		);

		// Model matrix : an identity matrix (model will be at the origin)
		var model = Matrix4.identity();
		// Our ModelViewProjection : multiplication of our 3 matrices
		// Remember, matrix multiplication is the other way around
		mvp = Matrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		// Create vertex buffer
		vertexBuffer = new VertexBuffer(
			Std.int(vertices.length / 3), // Vertex count - 3 floats per vertex
			structure, // Vertex structure
			Usage.StaticUsage // Vertex data will stay the same
		);

		// Copy vertices and uvs to vertex buffer
		var vbData = vertexBuffer.lock();
		for (i in 0...Std.int(vbData.length / structureLength)) {
			vbData[i * structureLength] = vertices[i * 3];
			vbData[i * structureLength + 1] = vertices[i * 3 + 1];
			vbData[i * structureLength + 2] = vertices[i * 3 + 2];
			vbData[i * structureLength + 3] = uvs[i * 2];
			vbData[i * structureLength + 4] = uvs[i * 2 + 1];
		}
		vertexBuffer.unlock();

		// A 'trick' to create indices for a non-indexed vertex data
		var indices:Array<Int> = [];
		for (i in 0...Std.int(vertices.length / 3)) {
			indices.push(i);
		}

		// Create index buffer
		indexBuffer = new IndexBuffer(
			indices.length, // Number of indices for our cube
			Usage.StaticUsage // Index data will stay the same
		);
		
		// Copy indices to index buffer
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = indices[i];
		}
		indexBuffer.unlock();

		Configuration.setScreen(this);
    }

	override public function render(frame:Framebuffer) {
		// A graphics object which lets us perform 3D operations
		var g = frame.g4;

		// Begin rendering
        g.begin();

        // Set depth mode
        g.setDepthMode(true, CompareMode.Less);

        // Clear screen
		g.clear(Color.fromFloats(0.0, 0.0, 0.3), 1.0);

		// Bind data we want to draw
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);

		// Bind shader program we want to draw with
		g.setProgram(program);

		// Set our transformation to the currently bound shader, in the "MVP" uniform
		g.setMatrix(mvpID, mvp);

		// Set texture
		g.setTexture(textureID, image);

		// Draw!
		g.drawIndexedVertices();

		// End rendering
		g.end();
    }
}

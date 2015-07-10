package ;

import kha.Game;
import kha.Framebuffer;
import kha.Color;
import kha.Loader;
import kha.LoadingScreen;
import kha.Configuration;
import kha.Image;
import kha.Scheduler;
import kha.Key;
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

	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var program:Program;

	var mvp:Matrix4;
	var mvpID:ConstantLocation;

	var model:Matrix4;
	var view:Matrix4;
	var projection:Matrix4;

	var textureID:TextureUnit;
    var image:Image;

    var lastTime = 0.0;

	var position:Vector3 = new Vector3(0, 0, 5); // Initial position: on +Z
	var horizontalAngle = 3.14; // Initial horizontal angle: toward -Z
	var verticalAngle = 0.0; // Initial vertical angle: none

	var moveForward = false;
    var moveBackward = false;
    var strafeLeft = false;
    var strafeRight = false;
	var isMouseDown = false;

	var mouseX = 0.0;
	var mouseY = 0.0;
	var mouseDeltaX = 0.0;
	var mouseDeltaY = 0.0;

	var speed = 3.0; // 3 units / second
	var mouseSpeed = 0.005;

	public function new() {
		super("Empty");
	}

	override public function init() {
        Configuration.setScreen(new LoadingScreen());

        // Load room with our texture and obj data
        Loader.the.loadRoom("room0", loadingFinished);
    }

	function loadingFinished() {
		// Define vertex structure
		var structure = new VertexStructure();
        structure.add("pos", VertexData.Float3);
        structure.add("uv", VertexData.Float2);
        structure.add("nor", VertexData.Float3);
        // Save length - we store position, uv and normal data
        var structureLength = 8;

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
		image = Loader.the.getImage("uvmap");

		// Projection matrix: 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
		projection = Matrix4.perspectiveProjection(45.0, 4.0 / 3.0, 0.1, 100.0);
		// Or, for an ortho camera
		//projection = Matrix4.orthogonalProjection(-10.0, 10.0, -10.0, 10.0, 0.0, 100.0); // In world coordinates
		
		// Camera matrix
		view = Matrix4.lookAt(new Vector3(4, 3, 3), // Camera is at (4, 3, 3), in World Space
							  new Vector3(0, 0, 0), // and looks at the origin
							  new Vector3(0, 1, 0) // Head is up (set to (0, -1, 0) to look upside-down)
		);

		// Model matrix: an identity matrix (model will be at the origin)
		model = Matrix4.identity();
		// Our ModelViewProjection: multiplication of our 3 matrices
		// Remember, matrix multiplication is the other way around
		mvp = Matrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		// Parse .obj file
		var obj = new ObjLoader(Loader.the.getBlob("cube").toString());
		var data = obj.data;
		var indices = obj.indices;

		// Create vertex buffer
		vertexBuffer = new VertexBuffer(
			Std.int(data.length / structureLength), // Vertex count
			structure, // Vertex structure
			Usage.StaticUsage // Vertex data will stay the same
		);

		// Copy data to vertex buffer
		var vbData = vertexBuffer.lock();
		for (i in 0...vbData.length) {
			vbData[i] = data[i];
		}
		vertexBuffer.unlock();

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

		// Add mouse and keyboard listeners
		kha.input.Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		kha.input.Keyboard.get().notify(onKeyDown, onKeyUp);

		// Used to calculate delta time
		lastTime = Scheduler.time();

		Configuration.setScreen(this);
    }

	override public function render(frame:Framebuffer) {
		// A graphics object which lets us perform 3D operations
		var g = frame.g4;

		// Begin rendering
        g.begin();

        // Set depth mode
        g.setDepthMode(true, CompareMode.Less);

        // Set culling
        g.setCullMode(kha.graphics4.CullMode.CounterClockwise);

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

    override public function update() {
    	// Compute time difference between current and last frame
		var deltaTime = Scheduler.time() - lastTime;
		lastTime = Scheduler.time();

		// Compute new orientation
		if (isMouseDown) {
			horizontalAngle += mouseSpeed * mouseDeltaX * -1;
			verticalAngle += mouseSpeed * mouseDeltaY * -1;
		}

		// Direction : Spherical coordinates to Cartesian coordinates conversion
		var direction = new Vector3(
			Math.cos(verticalAngle) * Math.sin(horizontalAngle),
			Math.sin(verticalAngle),
			Math.cos(verticalAngle) * Math.cos(horizontalAngle)
		);
		
		// Right vector
		var right = new Vector3(
			Math.sin(horizontalAngle - 3.14 / 2.0), 
			0,
			Math.cos(horizontalAngle - 3.14 / 2.0)
		);
		
		// Up vector
		var up = right.cross(direction);

		// Movement
		if (moveForward) {
			var v = direction.mult(deltaTime * speed);
			position = position.add(v);
		}
		if (moveBackward) {
			var v = direction.mult(deltaTime * speed * -1);
			position = position.add(v);
		}
		if (strafeRight) {
			var v = right.mult(deltaTime * speed);
			position = position.add(v);
		}
		if (strafeLeft) {
			var v = right.mult(deltaTime * speed * -1);
			position = position.add(v);
		}

		// Look vector
		var look = position.add(direction);
		
		// Camera matrix
		view = Matrix4.lookAt(position, // Camera is here
							  look, // and looks here : at the same position, plus "direction"
							  up // Head is up (set to (0, -1, 0) to look upside-down)
		);
		
		// Update model-view-projection matrix
		mvp = Matrix4.identity();
		mvp = mvp.multmat(projection);
		mvp = mvp.multmat(view);
		mvp = mvp.multmat(model);

		mouseDeltaX = 0;
		mouseDeltaY = 0;
    }

    function onMouseDown(button:Int, x:Int, y:Int) {
    	isMouseDown = true;
    }

    function onMouseUp(button:Int, x:Int, y:Int) {
    	isMouseDown = false;
    }

    function onMouseMove(x:Int, y:Int) {
    	mouseDeltaX = x - mouseX;
    	mouseDeltaY = y - mouseY;

    	mouseX = x;
    	mouseY = y;
    }

    function onKeyDown(key:Key, char:String) {
        if (key == Key.UP) moveForward = true;
        else if (key == Key.DOWN) moveBackward = true;
        else if (key == Key.LEFT) strafeLeft = true;
        else if (key == Key.RIGHT) strafeRight = true;
    }

    function onKeyUp(key:Key, char:String) {
        if (key == Key.UP) moveForward = false;
        else if (key == Key.DOWN) moveBackward = false;
        else if (key == Key.LEFT) strafeLeft = false;
        else if (key == Key.RIGHT) strafeRight = false;
    }
}

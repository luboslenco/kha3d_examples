package;

import kha.Game;
import kha.Framebuffer;
import kha.Color;

class Empty extends Game {

	public function new() {
		super("Empty");
	}

	override public function render(frame:Framebuffer) {
		// A graphics object which lets us perform 3D operations
		var g = frame.g4;

		// Begin rendering
        g.begin();

        // Clear screen to black
		g.clear(Color.Black);

		// End rendering
		g.end();
    }
}

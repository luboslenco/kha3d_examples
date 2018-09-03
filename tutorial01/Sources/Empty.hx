package;

import kha.Framebuffer;
import kha.Color;

class Empty {

	public function new() {

	}

	public function render(frames:Array<Framebuffer>) {
		// A graphics object which lets us perform 3D operations
		var g = frames[0].g4;

		// Begin rendering
        g.begin();

        // Clear screen to black
		g.clear(Color.Black);

		// End rendering
		g.end();
    }
}

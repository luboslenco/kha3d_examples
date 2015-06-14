package;

import kha.Game;
import kha.Framebuffer;

class Empty extends Game {

	public function new() {
		super("Empty", false);
	}

	override public function render(frame:Framebuffer) {
		var g = frame.g4;

        g.begin();
		g.clear(kha.Color.Black);
		g.end();
    }
}

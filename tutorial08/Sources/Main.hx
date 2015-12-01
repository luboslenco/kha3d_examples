package;

import kha.Scheduler;
import kha.System;

class Main {

	public static function main() {
		System.init("Empty", 640, 480, init);
	}

	static function init() {
		var game = new Empty();
		System.notifyOnRender(game.render);
		Scheduler.addTimeTask(game.update, 0, 1 / 60);
	}
}

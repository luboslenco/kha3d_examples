package;

import kha.Scheduler;
import kha.System;

class Main {

	public static function main() {
		System.start({title: "Empty", width: 640, height: 480}, init);
	}

	static function init(_) {
		var game = new Empty();
	}
}

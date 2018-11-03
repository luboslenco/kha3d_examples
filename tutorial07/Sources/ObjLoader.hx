package ;

class ObjLoader {

	static var indexedVertices:Array<Float>;
	static var indexedUVs:Array<Float>;
	static var index:Int;

	public var data:Array<Float>;
	public var indices:Array<Int>;

	public function new(blob:kha.Blob) {

		var vertices:Array<Float> = [];
		var uvs:Array<Float> = [];

		var vertexIndices:Array<Int> = [];
		var uvIndices:Array<Int> = [];

		var tempVertices:Array<Array<Float>> = [];
		var tempUVs:Array<Array<Float>> = [];

		var pos = 0;
		while (true) {

			if (pos >= blob.length) break;

			var line = "";

			while (true) {
				var c = String.fromCharCode(blob.readU8(pos));
				pos++;
				if (c == "\n") break;
				if (pos >= blob.length) break;
				line += c;
			}

			var words:Array<String> = line.split(" ");

			if (words[0] == "v") {
				var vector:Array<Float> = [];
				vector.push(Std.parseFloat(words[1]));
				vector.push(Std.parseFloat(words[2]));
				vector.push(Std.parseFloat(words[3]));
				tempVertices.push(vector);
			}
			else if (words[0] == "vt") {
				var vector:Array<Float> = [];
				vector.push(Std.parseFloat(words[1]));
				vector.push(Std.parseFloat(words[2]));
				tempUVs.push(vector);
			}
			else if (words[0] == "f") {
				var sec1:Array<String> = words[1].split("/");
				var sec2:Array<String> = words[2].split("/");
				var sec3:Array<String> = words[3].split("/");

				vertexIndices.push(Std.int(Std.parseFloat(sec1[0])));
				vertexIndices.push(Std.int(Std.parseFloat(sec2[0])));
				vertexIndices.push(Std.int(Std.parseFloat(sec3[0])));

				uvIndices.push(Std.int(Std.parseFloat(sec1[1])));
				uvIndices.push(Std.int(Std.parseFloat(sec2[1])));
				uvIndices.push(Std.int(Std.parseFloat(sec3[1])));
			}
		}

		for (i in 0...vertexIndices.length) {
			var vertex:Array<Float> = tempVertices[vertexIndices[i] - 1];
			var uv:Array<Float> = tempUVs[uvIndices[i] - 1];

			vertices.push(vertex[0]);
			vertices.push(vertex[1]);
			vertices.push(vertex[2]);
			uvs.push(uv[0]);
			uvs.push(uv[1]);
		}

		build(vertices, uvs);

		data = [];
		for (i in 0...Std.int(vertices.length / 3)) {
			data.push(indexedVertices[i * 3]);
			data.push(indexedVertices[i * 3 + 1]);
			data.push(indexedVertices[i * 3 + 2]);
			data.push(indexedUVs[i * 2]);
			data.push(1-indexedUVs[i * 2 + 1]);
		}
	}

	function build(vertices:Array<Float>, uvs:Array<Float>) {
		indexedVertices = [];
		indexedUVs = [];
		indices = [];

		// For each input vertex
		for (i in 0...Std.int(vertices.length / 3)) {

			// Try to find a similar vertex in out_XXXX
			var found:Bool = getSimilarVertexIndex(
				vertices[i * 3], vertices[i * 3 + 1], vertices[i * 3 + 2],
				uvs[i * 2], uvs[i * 2 + 1]);

			if (found) { // A similar vertex is already in the VBO, use it instead !
				indices.push(index);
			}else{ // If not, it needs to be added in the output data.
				indexedVertices.push(vertices[i * 3]);
				indexedVertices.push(vertices[i * 3 + 1]);
				indexedVertices.push(vertices[i * 3 + 2]);
				indexedUVs.push(uvs[i * 2 ]);
				indexedUVs.push(uvs[i * 2 + 1]);
				indices.push(Std.int(indexedVertices.length / 3) - 1);
			}
		}
	}

	// Returns true if v1 can be considered equal to v2
	function isNear(v1:Float, v2:Float):Bool {
		return Math.abs(v1 - v2) < 0.01;
	}

	// Searches through all already-exported vertices for a similar one.
	// Similar = same position + same UVs
	function getSimilarVertexIndex( 
		vertexX:Float, vertexY:Float, vertexZ:Float,
		uvX:Float, uvY:Float
	):Bool {
		// Lame linear search
		for (i in 0...Std.int(indexedVertices.length / 3)) {
			if (
				isNear(vertexX, indexedVertices[i * 3]) &&
				isNear(vertexY, indexedVertices[i * 3 + 1]) &&
				isNear(vertexZ, indexedVertices[i * 3 + 2]) &&
				isNear(uvX    , indexedUVs     [i * 2]) &&
				isNear(uvY    , indexedUVs     [i * 2 + 1])
			) {
				index = i;
				return true;
			}
		}
		// No other vertex could be used instead.
		// Looks like we'll have to add it to the VBO.
		return false;
	}
}

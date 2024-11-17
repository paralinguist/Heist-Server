shader_type canvas_item;

uniform bool override;
uniform vec2 positions[5];
uniform float threshold[5];
varying vec2 vert;

void vertex() {
	// Called for every vertex the material is visible on.
	vert = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 colStore = COLOR;
	if (!override) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
		for (int i = 0; i < 5; ++i) {
			if (distance(vert, positions[i]) < threshold[i])  {
				COLOR = colStore;
				break;
			}

		}
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

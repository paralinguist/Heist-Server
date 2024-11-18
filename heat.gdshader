shader_type canvas_item;

uniform float heat;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec2 position = UV / SCREEN_PIXEL_SIZE;
    vec2 maxes = vec2(1.0, 1.0)/ SCREEN_PIXEL_SIZE;
    COLOR =vec4(1.0, 0.0, 0.0, 1.0);
    float minx = min(position.x, maxes.x-position.x);
    float miny = min(position.y, maxes.y-position.y);
    float threshold = heat;
    float mincircx = threshold*2.0 - minx;
    float mincircy = threshold*2.0 - miny;
    bool validcirc = false;//minx < threshold*2.0 && miny < threshold*2.0 && length(vec2(mincircx, mincircy)) > threshold;
    if (min(minx, miny) < threshold || validcirc) {
        float alpha_val = 1.0- min(minx, miny)/threshold;
        COLOR = vec4(1.0, 0.2, 0.0, alpha_val);
    } else {
        COLOR = vec4(1.0, 0.2, 0.0, 0.0);
    }
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

uniform vec2 base_pos;
uniform vec2 base_size;

void vertex() {
	vec2 world = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	vec2 normalized = (world - base_pos) / base_size;
	COLOR = vec4(normalized, 0.3, 1.0);
}

void fragment() {
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

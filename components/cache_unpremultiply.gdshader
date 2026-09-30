shader_type canvas_item;
render_mode unshaded, blend_disabled;
// SubViewport stores premultiplied alpha; regular 2D texture draws need straight alpha.
void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	COLOR = pixel.a > 0.0001 ? vec4(pixel.rgb / pixel.a, pixel.a) : vec4(0.0);
}

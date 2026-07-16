shader_type canvas_item;

uniform vec2 uv_scale = vec2(1.0, 1.0);

void fragment() {
    // Multiply the texture color by the incoming COLOR (which holds your modulate values)
    COLOR = texture(TEXTURE, UV * uv_scale) * COLOR;
}
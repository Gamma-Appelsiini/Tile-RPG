shader_type canvas_item;

uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0, 1);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 base_color;

    // Detect if this is a flat stylebox (no real texture, just white)
    if (tex_color.rgb == vec3(1.0)) {
        base_color = COLOR;
    } else {
        base_color = tex_color;
    }

    vec4 noise_texture = texture(dissolve_texture, UV);
    base_color.a *= floor(dissolve_value + min(1.0, noise_texture.r));

    COLOR = base_color;
}
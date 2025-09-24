shader_type spatial;

render_mode unshaded;

uniform vec4 base_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // main color
uniform float bob_speed : hint_range(0.0, 10.0) = 1.0;             // bobbing speed
uniform float bob_amount : hint_range(0.0, 1.0) = 0.1;             // bobbing height
uniform vec4 fresnel_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // fresnel color
uniform float fresnel_intensity : hint_range(0.0, 5.0) = 1.0;         // fresnel strength

void vertex() {
    // Simple vertical bobbing (up/down movement in Y)
    float offset = sin(TIME * bob_speed) * bob_amount;
    VERTEX.y += offset;
}

void fragment() {
    // Fresnel effect
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.0);
    fresnel *= fresnel_intensity;

    vec4 color = base_color + fresnel * fresnel_color;
    ALBEDO = color.rgb;
    ALPHA = color.a;
}

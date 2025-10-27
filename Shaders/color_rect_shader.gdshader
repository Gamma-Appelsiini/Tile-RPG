shader_type canvas_item;

// 0.0 = fully invisible, 1.0 = fully visible
uniform float percentage : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // UV.y = 0 at bottom, 1 at top
    float y = UV.y;

    // This makes the visible area grow upward as percentage increases
    float visible = step(y, percentage);

    // Use the rect’s base color (the one set in the editor)
    COLOR = vec4(COLOR.rgb, COLOR.a * visible);
}


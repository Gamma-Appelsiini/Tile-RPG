shader_type canvas_item;

// --- Body Parameters ---
uniform vec4 tint_color : source_color = vec4(0.129, 0.306, 1.0, 0.29);
uniform float tint_opacity : hint_range(0.0, 1.0) = 1.0;

// --- Outline Parameters ---
uniform vec4 outline_color : source_color = vec4(0.251, 0.251, 0.251, 0.675);
uniform float outline_thickness : hint_range(0.0, 10.0) = 4;
uniform float outline_intensity : hint_range(0.0, 5.0) = 0.24;

void fragment() {
    // 1. Sample the base texture's alpha channel
    float base_alpha = texture(TEXTURE, UV).a;
    
    // 2. Calculate the outline by checking surrounding pixels
    float max_neighbor_alpha = 0.0;
    if (outline_thickness > 0.0) {
        int steps = int(ceil(outline_thickness));
        for (int x = -steps; x <= steps; x++) {
            for (int y = -steps; y <= steps; y++) {
                if (x == 0 && y == 0) continue;
                vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE * (outline_thickness / float(steps));
                max_neighbor_alpha = max(max_neighbor_alpha, texture(TEXTURE, UV + offset).a);
            }
        }
    }
    
    // Outline appears only in transparent areas surrounding the sprite
    float outline_mask = clamp(max_neighbor_alpha - base_alpha, 0.0, 1.0);
    float total_alpha = clamp(base_alpha + outline_mask, 0.0, 1.0);
    
    if (total_alpha <= 0.001) {
        discard;
    }
    
    // 3. Compute direct body and outline colors (independent of screen texture)
    vec3 body_rgb = tint_color.rgb;
    float body_alpha = base_alpha * tint_color.a * tint_opacity;
    
    vec3 outline_rgb = outline_color.rgb;
    float outline_alpha = outline_mask * outline_color.a * outline_intensity;
    
    // 4. Combine body and outline smoothly
    vec3 final_rgb = mix(outline_rgb, body_rgb, clamp(base_alpha, 0.0, 1.0));
    float final_alpha = clamp(body_alpha + outline_alpha, 0.0, 1.0);
    
    COLOR = vec4(final_rgb, final_alpha);
}
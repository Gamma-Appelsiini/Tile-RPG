shader_type canvas_item;

// --- Uniforms ---
uniform vec4 glow_color : source_color = vec4(0.6, 0.1, 0.1, 1.0); // Default: Blood Red
uniform float glow_speed : hint_range(0.0, 10.0) = 3.0;
uniform float glow_thickness : hint_range(0.0, 0.5) = 0.15;
uniform float glow_intensity : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    // 1. Calculate distance to the nearest edge
    // UV.x and UV.y go from 0.0 to 1.0
    float dist_x = min(UV.x, 1.0 - UV.x);
    float dist_y = min(UV.y, 1.0 - UV.y);
    float edge_dist = min(dist_x, dist_y);

    // 2. Create the pulsing logic
    // We map the sine wave from [-1, 1] to [1.0 - pulse_amount, 1.0]
    float pulse = (1.0 - pulse_amount) + (pulse_amount * (0.5 + 0.5 * sin(TIME * glow_speed)));

    // 3. Create the gradient mask
    // smoothstep(edge, smoothness, value)
    float mask = smoothstep(glow_thickness, 0.0, edge_dist);

    // 4. Final Color Output
    vec4 final_color = glow_color;
    
    // Apply the gradient mask, the pulse, and the intensity
    final_color.a *= mask * pulse * glow_intensity;

    COLOR = final_color;
}
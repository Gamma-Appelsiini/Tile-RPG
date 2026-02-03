shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

// --- Colors ---
uniform vec4 base_color : source_color = vec4(0.4, 0.1, 0.05, 1.0); 
uniform vec4 edge_color : source_color = vec4(1.0, 0.3, 0.1, 1.0); 

// --- Pulse Control ---
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.5; // 0 = no pulse, 1 = max pulse

// --- Textures ---
uniform sampler2D noise_tex : repeat_enable; 
uniform float noise_scale : hint_range(0.1, 5.0) = 1.0;

// --- Border Logic ---
uniform float edge_thickness : hint_range(0.0, 0.5) = 0.1;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.05;

void fragment() {
    // 1. Static Noise for texture detail
    vec2 scrolling_uv = UV * noise_scale;
    float n1 = texture(noise_tex, scrolling_uv + vec2(TIME * 0.05, TIME * 0.02)).r;
    float n2 = texture(noise_tex, scrolling_uv - vec2(TIME * 0.02, TIME * 0.05)).r;
    float combined_noise = (n1 + n2) * 0.5;

    // 2. Pulse Math - Calculated as a multiplier around 1.0
    // We use (pulse_intensity * 0.5) so it pulses above and below the base brightness
    float pulse = 1.0 + (sin(TIME * pulse_speed) * pulse_intensity);

    // 3. Distance from center (Square shape)
    vec2 centered_uv = abs(UV - vec2(0.5)) * 2.0;
    float dist = max(centered_uv.x, centered_uv.y);

    // 4. Edge Mask (The "Stable" Part)
    float border_threshold = 1.0 - edge_thickness;
    // We add a tiny bit of noise to the edge for "grit," but no pulse.
    float edge_mask = smoothstep(border_threshold - edge_softness, border_threshold, dist + (combined_noise * 0.02));
    
    // 5. Interior Glow (The "Pulsing" Part)
    // This targets only the area inside the border.
    float interior_factor = smoothstep(0.0, border_threshold, dist);
    float pulsing_glow = pow(interior_factor, 2.0) * pulse;

    // 6. Final Composition
    // The edge_color is added last to ensure it stays bright and stable.
    vec3 interior_color = base_color.rgb * pulsing_glow * combined_noise;
    vec3 final_rgb = mix(interior_color, edge_color.rgb, edge_mask);
    
    // Alpha logic: Edge is always visible, center fades based on noise and pulse
    float alpha_mask = mix(combined_noise * pulsing_glow, 1.0, edge_mask);
    
    ALBEDO = final_rgb;
    ALPHA = clamp(alpha_mask * base_color.a, 0.0, 1.0);
}

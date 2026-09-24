shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

// --- MASTER TOGGLES ---
group_uniforms Toggles;
uniform bool use_fresnel = true;
uniform bool use_pattern = true;
uniform bool use_hard_outline = true;
uniform bool use_pulsing = false;

// --- FRESNEL (SOFT GLOW) ---
group_uniforms Fresnel;
uniform vec4 fresnel_color : source_color = vec4(0.4, 0.0, 0.8, 1.0); // Dark fantasy purple
uniform float fresnel_power : hint_range(0.1, 10.0) = 3.0;
uniform float fresnel_intensity : hint_range(0.0, 10.0) = 2.0;
uniform bool fresnel_stepped = false; // Turn on for cel-shaded/stylized bands
uniform float fresnel_steps : hint_range(1.0, 10.0) = 3.0;

// --- PATTERN OVERLAY ---
group_uniforms Pattern;
uniform sampler2D pattern_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 pattern_color : source_color = vec4(0.1, 0.9, 0.5, 1.0); // Ethereal green
uniform vec2 pattern_uv_scale = vec2(2.0, 2.0);
uniform vec2 pattern_scroll_speed = vec2(0.1, -0.15);
uniform float pattern_intensity : hint_range(0.0, 10.0) = 1.0;
uniform bool pattern_mask_by_fresnel = true; // If true, pattern only shows on the edges

// --- HARD OUTLINE (INNER RIM) ---
group_uniforms HardOutline;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Dark ink/abyssal outline
uniform float outline_thickness : hint_range(0.0, 1.0) = 0.1;

// --- PULSE (BREATHING EFFECT) ---
group_uniforms Pulse;
uniform float pulse_speed : hint_range(0.1, 10.0) = 2.0;
uniform float pulse_min : hint_range(0.0, 1.0) = 0.2;
uniform float pulse_max : hint_range(0.0, 5.0) = 1.0;

// --- GLOBAL SETTINGS ---
group_uniforms Global;
uniform float global_opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Calculate the view angle for edge detection
    float view_dot = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    float fresnel = pow(1.0 - view_dot, fresnel_power);

    // Stylized stepped fresnel (toon shading logic)
    if (fresnel_stepped) {
        fresnel = floor(fresnel * fresnel_steps) / fresnel_steps;
    }

    vec3 final_color = vec3(0.0);
    float final_alpha = 0.0;

    // 1. FRESNEL GLOW
    if (use_fresnel) {
        final_color += fresnel_color.rgb * fresnel * fresnel_intensity;
        final_alpha += fresnel * fresnel_color.a;
    }

    // 2. SCROLLING PATTERN
    if (use_pattern) {
        vec2 scrolled_uv = UV * pattern_uv_scale + (TIME * pattern_scroll_speed);
        vec4 tex = texture(pattern_texture, scrolled_uv);

        // Optional: Constrain the magical texture to the edges of the mesh
        float mask = pattern_mask_by_fresnel ? fresnel : 1.0;
        
        vec3 p_color = tex.rgb * pattern_color.rgb * pattern_intensity * mask;

        // Additive blend the pattern color
        final_color += p_color;
        // Take the highest alpha so the pattern cuts through transparent areas
        final_alpha = max(final_alpha, tex.r * pattern_color.a * mask);
    }

    // 3. HARD OUTLINE
    if (use_hard_outline) {
        // Step function creates a harsh cutoff at the edge
        float outline_mask = step(1.0 - outline_thickness, 1.0 - view_dot);
        
        // Mix completely overrides the color at the very edge (perfect for dark fantasy ink lines)
        final_color = mix(final_color, outline_color.rgb, outline_mask * outline_color.a);
        final_alpha = max(final_alpha, outline_mask * outline_color.a);
    }

    // 4. PULSING / BREATHING
    float current_pulse = 1.0;
    if (use_pulsing) {
        float sine_wave = (sin(TIME * pulse_speed) + 1.0) / 2.0; // Normalized 0.0 to 1.0
        current_pulse = mix(pulse_min, pulse_max, sine_wave);
    }

    // 5. OUTPUT
    // Since render_mode is unshaded, ALBEDO acts directly as light output
    ALBEDO = final_color * current_pulse;
    ALPHA = clamp(final_alpha * current_pulse * global_opacity, 0.0, 1.0);
}
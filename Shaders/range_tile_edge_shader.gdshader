shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

// --- Colors ---
uniform vec4 base_color : source_color = vec4(0.4, 0.1, 0.05, 1.0); 
uniform vec4 edge_color : source_color = vec4(1.0, 0.3, 0.1, 1.0); 

// --- Pulse Control ---
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.5;

// --- Textures ---
uniform sampler2D noise_tex : repeat_enable; 
uniform float noise_scale : hint_range(0.1, 5.0) = 1.0;

// --- Border Logic ---
uniform float edge_thickness : hint_range(0.0, 0.5) = 0.1;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.05;

void fragment() {
    vec2 scrolling_uv = UV * noise_scale;
    float n1 = texture(noise_tex, scrolling_uv + vec2(TIME * 0.05, TIME * 0.02)).r;
    float n2 = texture(noise_tex, scrolling_uv - vec2(TIME * 0.02, TIME * 0.05)).r;
    float combined_noise = (n1 + n2) * 0.5;
    float pulse = 1.0 + (sin(TIME * pulse_speed) * pulse_intensity);

    // 1. Unpack the neighbor data from GDScript
    int mask = int(round(COLOR.r * 255.0));
    bool edge_t = (mask & 1) != 0;
    bool edge_r = (mask & 2) != 0;
    bool edge_b = (mask & 4) != 0;
    bool edge_l = (mask & 8) != 0;
    bool corner_tl = (mask & 16) != 0;
    bool corner_tr = (mask & 32) != 0;
    bool corner_br = (mask & 64) != 0;
    bool corner_bl = (mask & 128) != 0;

    // 2. Calculate pixel-perfect distance to the nearest outer boundary
    float closest_edge = 100.0;

    // Orthogonal (Straight) Edges
    if (edge_t) closest_edge = min(closest_edge, UV.y);
    if (edge_b) closest_edge = min(closest_edge, 1.0 - UV.y);
    if (edge_l) closest_edge = min(closest_edge, UV.x);
    if (edge_r) closest_edge = min(closest_edge, 1.0 - UV.x);

    // Inner Corners (Only calculate if the straight edges aren't blocking it)
    if (!edge_t && !edge_l && corner_tl) closest_edge = min(closest_edge, length(UV - vec2(0.0, 0.0)));
    if (!edge_t && !edge_r && corner_tr) closest_edge = min(closest_edge, length(UV - vec2(1.0, 0.0)));
    if (!edge_b && !edge_l && corner_bl) closest_edge = min(closest_edge, length(UV - vec2(0.0, 1.0)));
    if (!edge_b && !edge_r && corner_br) closest_edge = min(closest_edge, length(UV - vec2(1.0, 1.0)));

    // 3. Render logic (Same as before)
    float edge_mask = 1.0 - smoothstep(edge_thickness, edge_thickness + edge_softness, closest_edge + (combined_noise * 0.02));
    float interior_factor = 1.0 - smoothstep(edge_thickness, 0.5, closest_edge);
    float pulsing_glow = pow(interior_factor, 2.0) * pulse;

    vec3 interior_color = base_color.rgb * pulsing_glow * combined_noise;
    vec3 final_rgb = mix(interior_color, edge_color.rgb, edge_mask);
    float alpha_mask = mix(combined_noise * pulsing_glow, 1.0, edge_mask);
    
    ALBEDO = final_rgb;
    ALPHA = clamp(alpha_mask * base_color.a, 0.0, 1.0);
}
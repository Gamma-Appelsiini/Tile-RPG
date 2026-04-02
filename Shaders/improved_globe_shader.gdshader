shader_type spatial;
render_mode cull_back, depth_draw_opaque, unshaded;

group_uniforms Liquid_Settings;
uniform float liquid_amount : hint_range(-0.5, 1.5) = 1.5; // 0.0 empty, 1.0 full
uniform vec3 deep_color : source_color = vec3(0.3, 0.0, 0.0); // The dark core
uniform vec3 surface_color : source_color = vec3(1.0, 0.0, 0.0); // The brighter fluid
uniform vec3 foam_color : source_color = vec3(1.0, 0.4, 0.2); // The top cut line

group_uniforms Animation;
uniform float churn_speed : hint_range(0.0, 2.0) = 0.8;
uniform float wave_amplitude : hint_range(0.0, 0.2) = 0.05;

group_uniforms Noise_Textures;
// Use a seamless, cloud-like noise for Noise 1
uniform sampler2D noise_tex_primary : source_color, repeat_enable;
// Use a more detailed or cellular noise for Noise 2
uniform sampler2D noise_tex_warp : source_color, repeat_enable;

group_uniforms Volumetrics;
uniform float warp_strength : hint_range(0.0, 1.0) = 0.3;
uniform float inner_glow_power : hint_range(0.5, 8.0) = 2.5;
uniform float meniscus_thickness : hint_range(0.001, 0.1) = 0.02;

varying vec3 local_pos;
varying vec3 normal_view; // View space normal

void vertex() {
	local_pos = VERTEX;
	// Calculate wave on the Y axis for the liquid surface movement
	float wave = sin(VERTEX.x * 10.0 + TIME * 3.0) * cos(VERTEX.z * 10.0 + TIME * 2.5);

	// Pass normal for fresnel/volume calculation
	normal_view = NORMAL;
}

void fragment() {
	// 1. LIQUID HEIGHT CALCULATION
	// Normalize object height roughly -0.5 to 0.5 (depending on your mesh scale)
	// We add wave offset here based on world position or UV to keep it consistent
	float wave_phase = (local_pos.x + local_pos.z) * 5.0 + TIME * 2.0;
	float physical_wave = sin(wave_phase) * wave_amplitude * 0.5;

	// Map fill amount to mesh height (assuming mesh is ~1 unit tall centered at 0)
	float fill_level = (liquid_amount - 0.5) * 1.0;
	float current_height = local_pos.y;

	// Cutoff
	if (current_height > fill_level + physical_wave) {
		discard;
	}

	// 2. DOMAIN WARPING (The "Roiling" Effect)
	// Instead of just scrolling textures, we use one texture to distort the UVs of the other.
	vec2 uv_scroll = UV + vec2(TIME * 0.1 * churn_speed, TIME * 0.15 * churn_speed);

	// Sample the "Warper" noise
	vec3 warp_noise = texture(noise_tex_warp, uv_scroll).rgb;

	// Create distorted UVs based on that noise
	vec2 distorted_uv = UV + (warp_noise.rg * warp_strength) - (TIME * 0.05 * churn_speed);

	// Sample the Primary noise with distorted UVs
	float primary_noise = texture(noise_tex_primary, distorted_uv).r;

	// 3. COLOR MIXING
	// Mix deep and surface colors based on the churning noise
	vec3 fluid_col = mix(deep_color, surface_color, smoothstep(0.3, 0.8, primary_noise));

	// 4. FAKE VOLUME (Fresnel/Inner Glow)
	// In unshaded mode, spheres look flat. We add fake lighting based on the view angle.
	float NdotV = dot(normalize(normal_view), VIEW);
	float rim = 1.0 - max(NdotV, 0.0);

	// Darken the center (simulating density) and brighten the edges (simulating light scattering)
	// For blood/mana, usually the center is darker/richer.
	fluid_col = mix(fluid_col, deep_color * 0.5, pow(abs(NdotV), 1.5)); // Darker center
	fluid_col += surface_color * pow(rim, inner_glow_power) * 0.5; // Glowing edge

	// 5. MENISCUS (The Surface Line)
	// Calculate how close this pixel is to the top of the liquid
	float dist_to_surface = abs((fill_level + physical_wave) - current_height);

	// Create a sharp bright ring at the top
	float surface_line = 1.0 - smoothstep(0.0, meniscus_thickness, dist_to_surface);

	// Add the foam/surface line on top
	vec3 final_col = mix(fluid_col, foam_color, surface_line);

	ALBEDO = final_col;
}
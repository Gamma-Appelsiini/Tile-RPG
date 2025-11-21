shader_type spatial;

// Render modes:
// blend_mix: Standard blending
// depth_draw_always: Helps with transparency sorting
// cull_back: Hides inside faces (change to cull_disabled if you want to see back faces)
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

group_uniforms Colors;
uniform vec4 base_color : source_color = vec4(0.6, 0.8, 1.0, 0.4);
uniform vec4 deep_color : source_color = vec4(0.0, 0.2, 0.4, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

group_uniforms Surface;
// Use a FastNoiseLite texture here
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;
uniform float noise_scale = 1.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform float bump_strength : hint_range(0.0, 5.0) = 1.0;

group_uniforms Refraction_and_Fresnel;
uniform float refraction_strength : hint_range(0.0, 1.0) = 0.05;
uniform float fresnel_power : hint_range(0.5, 10.0) = 3.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// 1. Handle UVs and Noise
	vec2 uv = UV * noise_scale;
	float noise_val = texture(noise_texture, uv).r;

	// 2. Calculate "Fake" Normals from Noise (Bump Map)
	// This avoids needing a separate normal map. We look at neighboring pixels in the noise.
	float d = 0.005; // small offset
	float h_up = texture(noise_texture, uv + vec2(0.0, -d)).r;
	float h_down = texture(noise_texture, uv + vec2(0.0, d)).r;
	float h_left = texture(noise_texture, uv + vec2(-d, 0.0)).r;
	float h_right = texture(noise_texture, uv + vec2(d, 0.0)).r;

	vec3 bump_normal = normalize(vec3(
		(h_left - h_right) * bump_strength,
		(h_up - h_down) * bump_strength,
		1.0 // Z assumes flat surface initially
	));

	// Apply bump to the surface normal
	NORMAL_MAP = bump_normal;

	// 3. Fresnel Effect (Brighter edges)
	// Calculate how much the surface is facing the camera
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);

	// 4. Refraction (Looking through the ice)
	// We offset the screen lookup based on the normal map
	vec2 offset = (NORMAL_MAP.xy * refraction_strength);
	vec3 bg_texture = texture(screen_texture, SCREEN_UV + offset).rgb;

	// 5. Color Mixing
	// Mix the background (refraction) with the deep ice color
	vec3 inner_color = mix(bg_texture, deep_color.rgb, deep_color.a);
	// Mix the inner color with the base surface color
	vec3 surface_color = mix(inner_color, base_color.rgb, base_color.a);
	// Add the white edges based on fresnel
	vec3 final_color = mix(surface_color, edge_color.rgb, fresnel * edge_color.a);

	// 6. Final Output assignments
	ALBEDO = final_color;

	// Vary roughness based on noise (frosted parts vs smooth parts)
	ROUGHNESS = roughness + (noise_val * 0.2);

	// High specular for shiny ice
	SPECULAR = 0.5;
	METALLIC = 0.1; // Ice is dielectric, but a tiny bit of metallic helps the "shine" in game engines
}
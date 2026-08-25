shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

group_uniforms Base_Settings;
uniform vec4 primary_color : source_color = vec4(0.25, 0.55, 1.0, 1.0);
uniform sampler2D skill_texture : hint_default_black, filter_linear_mipmap;
uniform float skill_scale : hint_range(0.5, 3.0) = 1.2;

group_uniforms Depth_And_Reflection;
uniform float parallax_depth : hint_range(-0.5, 0.5) = 0.2;
uniform float swirl_speed : hint_range(-2.0, 2.0) = 0.3;
uniform float swirl_distortion : hint_range(0.0, 0.3) = 0.05;

group_uniforms Elemental_Mist;
uniform sampler2D noise_texture : hint_default_white, filter_linear_mipmap;
uniform float mist_speed : hint_range(0.0, 2.0) = 0.25;
uniform float mist_density : hint_range(0.0, 3.0) = 1.2;

group_uniforms Glass_And_Glow;
uniform float fresnel_power : hint_range(0.5, 8.0) = 3.5;
uniform float fresnel_glow_intensity : hint_range(0.0, 5.0) = 2.5;
uniform float icon_emission : hint_range(0.0, 10.0) = 3.0;
uniform float surface_roughness : hint_range(0.0, 1.0) = 0.08;
uniform float surface_metallic : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	// 1. Calculate Fresnel edge highlight for crystalline orb shell
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);

	// 2. Parallax depth offset using view vector (creates "floating interior" illusion)
	vec2 view_offset = VIEW.xy * parallax_depth;

	// 3. Animated noise distortion for fluid elemental mist inside orb
	vec2 mist_uv1 = UV * 2.0 + vec2(TIME * mist_speed * 0.5, TIME * mist_speed * 0.3);
	vec2 mist_uv2 = UV * 1.5 - vec2(TIME * mist_speed * 0.3, TIME * mist_speed * 0.6);
	float mist_val1 = texture(noise_texture, mist_uv1).r;
	float mist_val2 = texture(noise_texture, mist_uv2).r;
	float combined_mist = (mist_val1 + mist_val2) * 0.5;

	// 4. Transform UVs for the inner skill icon (center, scale, rotate, distort)
	vec2 centered_uv = (UV - vec2(0.5));
	
	float angle = TIME * swirl_speed;
	mat2 rot_matrix = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	
	vec2 distorted_uv = centered_uv + view_offset + vec2(combined_mist - 0.5) * swirl_distortion;
	vec2 final_skill_uv = (rot_matrix * distorted_uv) * skill_scale + vec2(0.5);

	// 5. Mask icon UVs to keep texture centered without repeating edges
	float uv_mask = step(0.0, final_skill_uv.x) * step(final_skill_uv.x, 1.0) 
	              * step(0.0, final_skill_uv.y) * step(final_skill_uv.y, 1.0);
	
	vec4 skill_tex = texture(skill_texture, final_skill_uv) * uv_mask;

	// 6. Blend interior layers (dark void core + primary color mist + glowing skill icon)
	vec3 core_color = primary_color.rgb * 0.1;
	vec3 mist_color = primary_color.rgb * combined_mist * mist_density;
	vec3 icon_color = skill_tex.rgb * primary_color.rgb * icon_emission;

	vec3 interior_composite = mix(core_color + mist_color, icon_color, skill_tex.a * uv_mask);

	// 7. Surface PBR output
	ALBEDO = mix(core_color, interior_composite, 0.85);
	ROUGHNESS = surface_roughness;
	METALLIC = surface_metallic;
	
	// Emission drives WorldEnvironment Glow/Bloom (Diablo/DOS2 dark fantasy style)
	EMISSION = interior_composite + (primary_color.rgb * fresnel * fresnel_glow_intensity);
}
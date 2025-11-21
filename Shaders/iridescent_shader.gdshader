shader_type spatial;

// Render modes
// depth_draw_always: Essential for transparent sorting
// specular_schlick_ggx: High quality highlights
render_mode blend_mix, depth_draw_always, cull_back, specular_schlick_ggx;

group_uniforms Gem_Properties;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 0.1); // Keep alpha low for transparency
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform float specular : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0; // Gems are dielectric, but tweaking this can help style

group_uniforms Iridescence;
// The gradient texture for the "Fire" of the diamond
uniform sampler2D iridescence_gradient : source_color, filter_linear, repeat_disable; 
uniform float iridescence_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float fresnel_power : hint_range(0.5, 10.0) = 4.0;

group_uniforms Refraction;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float refraction_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float aberration_amount : hint_range(0.0, 0.1) = 0.02; // Distance between RGB split

void fragment() {
	// 1. Calculate Fresnel
	// This determines how "edge-on" the view is to the surface normal
	float NdotV = dot(NORMAL, VIEW);
	float fresnel = pow(1.0 - clamp(NdotV, 0.0, 1.0), fresnel_power);

	// 2. Sample the Gradient (Iridescence)
	// We map the fresnel value to the U coordinate of the gradient texture
	vec3 fire_color = texture(iridescence_gradient, vec2(fresnel, 0.5)).rgb;

	// 3. Refraction with Chromatic Aberration (The "Diamond" split)
	// Instead of one screen sample, we take 3 (R, G, B) at slightly different offsets
	vec2 uv_offset = NORMAL.xy * refraction_intensity;
	
	// Red channel (offset negative)
	float r = texture(screen_texture, SCREEN_UV + uv_offset * (1.0 - aberration_amount)).r;
	// Green channel (center)
	float g = texture(screen_texture, SCREEN_UV + uv_offset).g;
	// Blue channel (offset positive)
	float b = texture(screen_texture, SCREEN_UV + uv_offset * (1.0 + aberration_amount)).b;
	
	vec3 refraction_color = vec3(r, g, b);

	// 4. Combine Everything
	
	// Mix the refraction with the base color tint
	vec3 final_albedo = mix(refraction_color, base_color.rgb, base_color.a);
	
	// Add the iridescence "fire" on top based on fresnel intensity
	final_albedo += fire_color * iridescence_intensity * fresnel;
	
	ALBEDO = final_albedo;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	METALLIC = metallic;
}
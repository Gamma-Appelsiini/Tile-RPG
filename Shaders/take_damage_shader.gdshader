shader_type spatial;

// Render Mode settings:
// unshaded: We want the hurt glow to shine bright regardless of lighting.
// blend_mix: Standard blending over the character.
// cull_back: Standard face culling.
// depth_draw_always: Ensures transparent sorting works well over the base mesh.
render_mode blend_mix, cull_back, unshaded, depth_draw_always;

group_uniforms Appearance;
uniform vec4 hurt_color : source_color = vec4(0.8, 0.1, 0.1, 1.0);
uniform float active_strength : hint_range(0.0, 1.0) = 0.0; // Master fader (0 = invisible, 1 = full hurt)
uniform float erosion_amount : hint_range(0.0, 1.0) = 0.0; // Eats away the color for a patchy look

group_uniforms Wobble_Distortion;
uniform sampler2D noise_texture : filter_linear_mipmap, repeat_enable;
uniform float wobble_intensity : hint_range(0.0, 0.5) = 0.05; // How far vertices move
uniform float wobble_speed : hint_range(0.0, 10.0) = 2.0;

group_uniforms Fantasy_Effects;
uniform float fresnel_power : hint_range(0.5, 8.0) = 2.5; // Glowing edges
uniform float emission_strength : hint_range(1.0, 10.0) = 3.0; // Brightness of the glow

varying float noise_val; // Pass noise from Vertex to Fragment for sync

void vertex() {
	// 1. Sample Noise for Displacement
	// We use world position + time to make the wobble continuous across UV seams
	vec2 noise_uv = UV + (vec2(0.0, TIME * wobble_speed));
	noise_val = texture(noise_texture, noise_uv).r;

	// 2. Expand the Mesh (Wobble)
	// We push vertices out along their Normal vector based on the noise.
	// We multiply by active_strength so the mesh snaps back to normal when not hurt.
	float displacement = (noise_val * wobble_intensity) * active_strength;
	VERTEX += NORMAL * displacement;
}

void fragment() {
	// 1. Calculate Fresnel (Rim Light)
	// This makes the edges glow brighter, looking like magical energy or spirit pressure
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);

	// 2. Create Organic Patchiness
	// We use the noise value to create gaps in the color, so it looks like
	// energy crackling over the skin rather than a flat plastic wrapper.
	float erosion = smoothstep(erosion_amount - 0.2, erosion_amount + 0.2, noise_val);

	// 3. Combine Color and Glow
	vec3 final_color = hurt_color.rgb * emission_strength;

	// Mix the center color with even brighter edges
	final_color = mix(final_color, final_color * 1.5, fresnel);

	// 4. Apply Output
	ALBEDO = final_color;

	// 5. Calculate Alpha
	// The shader is invisible if active_strength is 0.
	// We combine the master strength, the fresnel rim, and the erosion pattern.
	float alpha_base = (hurt_color.a * 0.5) + (fresnel * 0.5); // Rim is always more opaque
	ALPHA = clamp(alpha_base * active_strength * erosion, 0.0, 1.0);
}
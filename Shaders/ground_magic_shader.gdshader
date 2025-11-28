shader_type spatial;
// Additive blending is key for magic effects (black becomes transparent, colors add light)
render_mode blend_add, cull_disabled, unshaded, depth_draw_never;

group_uniforms Textures;
// The white-on-black texture you have
uniform sampler2D main_texture : source_color, filter_linear_mipmap;
// A noise texture (seamless) to create the "flowing energy" look inside the lines
uniform sampler2D energy_noise : filter_linear_mipmap, repeat_enable;
// New: A Normal Map or Noise texture to distort the circle, giving it "fluid" depth
uniform sampler2D distortion_texture : hint_normal, filter_linear_mipmap, repeat_enable;

group_uniforms Coloring;
// The color of the magic. Use HDR values (Raw > 1.0) for Bloom!
uniform vec4 emission_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
// Controls how transparent the whole effect is
uniform float transparency : hint_range(0.0, 1.0) = 1.0;

group_uniforms Movement;
// Speed of the circle rotation (radians per second)
uniform float rotation_speed = 0.5;
// How fast the energy noise scrolls
uniform vec2 noise_scroll_speed = vec2(0.2, 0.1);
// New: How fast the distortion texture moves
uniform vec2 distortion_scroll_speed = vec2(0.1, 0.1);
// New: How strongly the texture is warped (0.05 is usually good)
uniform float distortion_strength : hint_range(0.0, 0.2) = 0.05;

// How fast the brightness pulses
uniform float pulse_speed = 2.0;
// How much the brightness pulses (0.0 = steady, 1.0 = heavy strobe)
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.2;

// --- Helper Function: Rotate UV ---
vec2 rotate_uv(vec2 uv, vec2 pivot, float rotation) {
	float sina = sin(rotation);
	float cosa = cos(rotation);
	uv -= pivot;
	return vec2(
		cosa * uv.x - sina * uv.y,
		cosa * uv.y + sina * uv.x
	) + pivot;
}

void fragment() {
	// 1. Calculate Distortion (The "Depth")
	// We sample a texture moving across the surface to create offsets
	vec2 distortion_uv = UV + (TIME * distortion_scroll_speed);
	vec3 distortion_sample = texture(distortion_texture, distortion_uv).rgb;
	// Convert standard normal map (0.0 to 1.0) to vector direction (-1.0 to 1.0)
	// If using a regular grayscale noise, you can just use (sample.rg) without the *2.0-1.0 math,
	// but this formula works best for purple-ish Normal Maps.
	vec2 distortion_offset = (distortion_sample.xy * 2.0 - 1.0) * distortion_strength;

	// 2. Calculate Rotation
	// We rotate the UVs over time to spin the circle
	vec2 centered_uv = UV;
	float current_rotation = TIME * rotation_speed;
	vec2 rotated_uv = rotate_uv(centered_uv, vec2(0.5), current_rotation);

	// 3. Sample the Main Texture WITH Distortion
	// We add the distortion offset to the rotated UVs.
	// This makes the lines of the circle "wiggle" like heat haze.
	vec4 magic_tex = texture(main_texture, rotated_uv + distortion_offset);

	// 4. Sample the Energy Noise
	// We scroll the noise over time to simulate flowing mana
	vec2 noise_uv = UV + (TIME * noise_scroll_speed);
	// We can also distort the noise for extra turbulence if we want
	float noise_val = texture(energy_noise, noise_uv + distortion_offset).r;

	// 5. Calculate Pulsing
	// Create a sine wave that goes between (1.0 - intensity) and 1.0
	float pulse = 1.0 - (pulse_intensity * 0.5) + (sin(TIME * pulse_speed) * pulse_intensity * 0.5);

	// 6. Combine Logic
	// We use the texture's R channel as a mask (assuming white on black)
	float mask = magic_tex.r;

	// We multiply the noise into the mask.
	// The 'mix' ensures the noise doesn't make the circle disappear completely,
	// just modulates its intensity for a "shimmering" look.
	float energy_pattern = mix(0.4, 1.0, noise_val);

	// 7. Circular Edge Fade (Soft Particle)
	// This ensures that if your texture hits the edge of the mesh, it fades out softly
	float dist_from_center = distance(UV, vec2(0.5));
	float edge_fade = 1.0 - smoothstep(0.45, 0.5, dist_from_center);

	// 8. Final Alpha/Emission Calculation
	float final_alpha = mask * energy_pattern * pulse * edge_fade * transparency;

	// Apply color. Since we are Unshaded + Additive, Albedo acts as the tint.
	ALBEDO = emission_color.rgb;
	ALPHA = final_alpha * emission_color.a;
}
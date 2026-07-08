shader_type canvas_item;

// The main color of the stat (e.g. green for Agility, red for Endurance, etc.)
uniform vec4 stat_color : source_color = vec4(0.8, 0.2, 0.2, 1.0);

// Secondary color for the gradient shading (usually darker, gives it depth)
uniform vec4 shade_color : source_color = vec4(0.15, 0.05, 0.05, 1.0);

// Direction-ish gradient blend strength (0 = flat color, 1 = full gradient)
uniform float gradient_strength : hint_range(0.0, 1.0) = 0.6;

// Outline
uniform vec4 outline_color : source_color = vec4(0.05, 0.04, 0.03, 1.0);
uniform float outline_width : hint_range(0.0, 4.0) = 1.2;

// Soft outer glow (subtle magic/gilded feel)
uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float glow_strength : hint_range(0.0, 1.0) = 0.0;
uniform float glow_size : hint_range(0.0, 8.0) = 2.0;

// Slight desaturation/darkening for "worn metal" feel, and overall brightness
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec2 uv = UV;
	vec4 tex = texture(TEXTURE, uv);
	vec2 texel = TEXTURE_PIXEL_SIZE;

	// --- Base recolor with vertical gradient (top lighter, bottom darker) ---
	float grad = clamp(uv.y * 1.4 - 0.2, 0.0, 1.0);
	vec3 base_rgb = mix(stat_color.rgb, shade_color.rgb, grad * gradient_strength);
	base_rgb *= brightness;

	vec4 col = vec4(base_rgb, tex.a) * stat_color.a;
	col.rgb *= tex.rgb; // preserve any internal shading baked into the white icon

	// --- Outline: sample alpha in a ring around this pixel ---
	float outline_alpha = 0.0;
	if (outline_width > 0.0 && tex.a < 0.9) {
		float max_a = 0.0;
		int samples = 8;
		for (int i = 0; i < samples; i++) {
			float angle = float(i) / float(samples) * TAU;
			vec2 offset = vec2(cos(angle), sin(angle)) * texel * outline_width;
			max_a = max(max_a, texture(TEXTURE, uv + offset).a);
		}
		outline_alpha = max_a * (1.0 - tex.a);
	}

	// --- Soft glow (wider ring, additive-ish) ---
	float glow_alpha = 0.0;
	if (glow_strength > 0.0 && tex.a < 0.9) {
		float max_a = 0.0;
		int samples = 12;
		for (int i = 0; i < samples; i++) {
			float angle = float(i) / float(samples) * TAU;
			vec2 offset = vec2(cos(angle), sin(angle)) * texel * (outline_width + glow_size);
			max_a = max(max_a, texture(TEXTURE, uv + offset).a);
		}
		glow_alpha = max_a * (1.0 - tex.a) * glow_strength;
	}

	// Composite: icon on top of outline on top of glow
	vec4 result = mix(vec4(glow_color.rgb, glow_alpha * glow_color.a), vec4(0.0), 1.0 - glow_alpha);
	result = mix(result, vec4(outline_color.rgb, outline_color.a), outline_alpha);
	result = mix(result, col, tex.a);

	COLOR = result;
}
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// ─────────────────────────────────────────────
//  BASE COLOR & TRANSPARENCY
// ─────────────────────────────────────────────
uniform vec4 gem_color : source_color = vec4(0.15, 0.05, 0.55, 1.0);
uniform float gem_transparency : hint_range(0.0, 1.0) = 0.18;
uniform float interior_brightness : hint_range(0.0, 5.0) = 2.2;

// ─────────────────────────────────────────────
//  PRISMATIC RAINBOW GRADIENT
//  Assign a gradient texture in the Inspector.
//  Default rainbow left→right: red→orange→yellow→green→cyan→blue→violet
// ─────────────────────────────────────────────
uniform sampler2D prism_gradient : source_color, hint_default_white;
uniform float prism_intensity : hint_range(0.0, 3.0) = 1.4;
uniform float prism_sharpness : hint_range(0.5, 16.0) = 4.0;
uniform float prism_scale : hint_range(0.1, 8.0) = 2.0;
uniform float prism_speed : hint_range(0.0, 4.0) = 0.35;  // shimmer animation speed
uniform float prism_fresnel_power : hint_range(0.5, 8.0) = 2.5;

// ─────────────────────────────────────────────
//  FACET / SPARKLE
// ─────────────────────────────────────────────
uniform float facet_sparkle_intensity : hint_range(0.0, 5.0) = 1.8;
uniform float facet_sparkle_size : hint_range(1.0, 128.0) = 32.0;
uniform float facet_sparkle_speed : hint_range(0.0, 4.0) = 0.6;

// ─────────────────────────────────────────────
//  SPECULAR & REFLECTIONS
// ─────────────────────────────────────────────
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform float specular_strength : hint_range(0.0, 2.0) = 1.0;
uniform vec4 specular_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// ─────────────────────────────────────────────
//  INTERNAL GLOW (dark fantasy luster)
// ─────────────────────────────────────────────
uniform vec4 glow_color : source_color = vec4(0.4, 0.1, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 8.0) = 1.6;
uniform float glow_fresnel_power : hint_range(0.5, 6.0) = 1.8;

// ─────────────────────────────────────────────
//  DEPTH / DEPTH FAKE
// ─────────────────────────────────────────────
uniform float depth_darkening : hint_range(0.0, 1.0) = 0.55;
uniform float depth_layers : hint_range(1.0, 6.0) = 3.0;

// ─────────────────────────────────────────────
//  ENVIRONMENT REFLECTION FAKE
// ─────────────────────────────────────────────
uniform float env_reflection_strength : hint_range(0.0, 2.0) = 0.7;
uniform vec4 env_color_a : source_color = vec4(0.05, 0.0, 0.15, 1.0); // dark void
uniform vec4 env_color_b : source_color = vec4(0.8, 0.6, 1.0, 1.0);   // bright highlight

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────

// Hash – fast pseudo-random from a vec2
float hash21(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

// Smooth voronoi – used for sparkling facet cells
float voronoi(vec2 uv, float scale) {
	uv *= scale;
	vec2 id = floor(uv);
	vec2 gv = fract(uv) - 0.5;
	float min_dist = 1e9;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 offset = vec2(float(x), float(y));
			vec2 cell = id + offset;
			vec2 r = offset - gv + vec2(
				hash21(cell),
				hash21(cell + vec2(7.3, 2.1))
			);
			float d = dot(r, r);
			min_dist = min(min_dist, d);
		}
	}
	return sqrt(min_dist);
}

// Animated prism sample – returns rainbow color for a direction
vec3 sample_prism(vec3 view_dir, vec3 normal, float time) {
	// Refraction-like offset driven by view angle + time drift
	vec3 refracted = refract(view_dir, normal, 0.85);
	float u = dot(refracted, vec3(1.0, 0.0, 0.0)) * prism_scale
			+ sin(time * prism_speed + refracted.y * 3.14) * 0.15;
	u = fract(u * 0.5 + 0.5);

	// Second lobe for richer color spread
	float u2 = dot(refracted, vec3(0.0, 1.0, 0.0)) * prism_scale * 0.7
			 + cos(time * prism_speed * 0.8 + refracted.z * 2.5) * 0.1;
	u2 = fract(u2 * 0.5 + 0.5 + 0.33);

	vec3 c1 = texture(prism_gradient, vec2(u, 0.5)).rgb;
	vec3 c2 = texture(prism_gradient, vec2(u2, 0.5)).rgb;

	// Blend lobes with sharpness
	float blend = pow(abs(dot(normal, -view_dir)), prism_sharpness * 0.5);
	return mix(c1, c2, blend);
}

// ─────────────────────────────────────────────
//  VERTEX
// ─────────────────────────────────────────────
varying vec3 world_normal;
varying vec3 world_pos;
varying vec3 obj_pos;

void vertex() {
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	world_pos    = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	obj_pos      = VERTEX;
}

// ─────────────────────────────────────────────
//  FRAGMENT
// ─────────────────────────────────────────────
void fragment() {
	float time = TIME;

	vec3 N = normalize(world_normal);
	vec3 V = normalize(CAMERA_POSITION_WORLD - world_pos); // view direction (toward camera)
	float NdotV = max(dot(N, V), 0.0);

	// ── Fresnel ───────────────────────────────
	float fresnel = pow(1.0 - NdotV, prism_fresnel_power);
	float glow_fresnel = pow(1.0 - NdotV, glow_fresnel_power);

	// ── Base gem color ────────────────────────
	vec3 base = gem_color.rgb * interior_brightness;

	// ── Fake depth darkening (center is deeper, darker) ──
	float depth_fade = pow(NdotV, depth_layers);
	base = mix(base * (1.0 - depth_darkening), base, depth_fade);

	// ── Fake environment reflection ───────────
	vec3 env = mix(env_color_a.rgb, env_color_b.rgb, pow(NdotV, 1.5));
	base = mix(base, base + env * env_reflection_strength, fresnel);

	// ── Prismatic rainbow ─────────────────────
	vec3 prism = sample_prism(-V, N, time);
	// Fresnel-weighted: stronger at glancing angles, also present at center
	float prism_mask = mix(0.3, 1.0, fresnel);
	base += prism * prism_intensity * prism_mask;

	// ── Voronoi facet sparkles ────────────────
	// Use UV of the screen-space normal projection for facet cells
	vec2 facet_uv = N.xy * 0.5 + vec2(
		sin(time * facet_sparkle_speed * 0.3) * 0.1,
		cos(time * facet_sparkle_speed * 0.2) * 0.1
	);
	float vor = voronoi(facet_uv, facet_sparkle_size * 0.1);
	// Sharp bright edges = facet glint
	float sparkle = pow(max(0.0, 1.0 - vor * 3.5), 6.0);
	// Animate sparkles blinking
	float blink = sin(time * facet_sparkle_speed + hash21(facet_uv * 3.7) * 6.28) * 0.5 + 0.5;
	sparkle *= blink;
	// Tint sparkle with prism color
	vec3 sparkle_color = mix(vec3(1.0), prism, 0.6);
	base += sparkle_color * sparkle * facet_sparkle_intensity;

	// ── Internal glow (rim + core) ────────────
	float rim_glow = glow_fresnel;          // bright at edges
	float core_glow = 1.0 - depth_fade;    // bright at shallow center
	base += glow_color.rgb * (rim_glow * 0.6 + core_glow * 0.4) * glow_intensity;

	// ── Output ───────────────────────────────
	ALBEDO    = clamp(base, 0.0, 1.0);
	METALLIC  = 0.0;
	ROUGHNESS = roughness;
	SPECULAR  = specular_strength;

	// Alpha: gem body is mostly opaque but slightly transparent at center
	float alpha = mix(1.0 - gem_transparency, 1.0, fresnel);
	ALPHA = clamp(alpha, 0.0, 1.0);

	// Emission: internal glow + prism shimmer contribute to self-illumination
	vec3 emission = glow_color.rgb * glow_intensity * (rim_glow * 0.4 + core_glow * 0.2);
	emission += prism * prism_intensity * sparkle * 0.5;
	EMISSION = clamp(emission, 0.0, 8.0);
}
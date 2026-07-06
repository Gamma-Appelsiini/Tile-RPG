shader_type canvas_item;

uniform bool is_crit = false;

// Overall lifetime progress, 0 = just spawned, 1 = fully gone.
// Set this every frame from a Tween in the driving script.
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Fraction of total lifetime spent on the spawn pop and the fade/dissolve.
uniform float spawn_frac = 0.15;
uniform float fade_frac = 0.35;

// Colors
uniform vec4 normal_color : source_color = vec4(0.92, 0.90, 0.85, 1.0);
uniform vec4 crit_color : source_color = vec4(1.0, 0.55, 0.08, 1.0);
uniform vec4 burn_color : source_color = vec4(1.4, 0.5, 0.05, 1.0); // >1 so it blooms

uniform float glow_strength = 1.0;

// Motion
uniform float float_distance = 46.0; // px drifted upward over lifetime
uniform float drift_x = 0.0;         // px, set randomly per instance from script
uniform float seed = 0.0;            // randomizes pulse/dissolve per instance

// ---------------- helpers ----------------

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// "back out" ease — overshoots past 1.0 then settles, gives a satisfying punch
float back_out(float t, float s) {
	float t2 = t - 1.0;
	return t2 * t2 * ((s + 1.0) * t2 + s) + 1.0;
}

// ---------------- vertex ----------------

void vertex() {
	float spawn_t = clamp(progress / spawn_frac, 0.0, 1.0);
	float fade_start = 1.0 - fade_frac;
	float fade_t = clamp((progress - fade_start) / fade_frac, 0.0, 1.0);

	// Punch-in scale: bigger overshoot for crits so they feel heavier.
	float overshoot = is_crit ? 2.4 : 1.3;
	float scale_in = 0.35 + 0.65 * back_out(spawn_t, overshoot);

	// Slight shrink while dissolving away at the end.
	float scale_out = mix(1.0, 0.82, fade_t);

	float final_scale = scale_in * scale_out;
	VERTEX *= final_scale;

	// Upward float — eased so it starts fast, slows near the end.
	float rise_t = pow(progress, 0.6);
	VERTEX.y -= float_distance * rise_t;

	// Horizontal drift, plus a quick shudder on crits right as they land.
	float shudder = is_crit ? sin(progress * 45.0 + seed * 20.0) * 3.5 * (1.0 - spawn_t) : 0.0;
	VERTEX.x += drift_x * progress + shudder;
}

// ---------------- fragment ----------------

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 base_color = is_crit ? crit_color : normal_color;

	// Slow ember-like pulse for normal hits, faster hotter pulse for crits.
	float pulse = 0.5 + 0.5 * sin(TIME * (is_crit ? 9.0 : 3.0) + seed * 6.2831);
	float glow = glow_strength * (is_crit ? 1.6 : 0.45) * pulse;

	vec3 col = base_color.rgb * (1.0 + glow);

	// Brief white-hot flash on the impact frame, crits only.
	float flash = is_crit ? (1.0 - smoothstep(0.0, 0.10, progress)) : 0.0;
	col = mix(col, vec3(1.2), flash * 0.85);

	float alpha = tex_color.a;

	// Fade in on spawn.
	float spawn_t = clamp(progress / spawn_frac, 0.0, 1.0);
	float in_alpha = smoothstep(0.0, 1.0, spawn_t);

	// Dissolve/burn-away on exit instead of a flat fade — fits the theme better.
	float fade_start = 1.0 - fade_frac;
	float fade_t = clamp((progress - fade_start) / fade_frac, 0.0, 1.0);

	float n = value_noise(UV * 18.0 + seed * 13.7);
	float dissolve = smoothstep(fade_t - 0.12, fade_t, n);
	float edge = (1.0 - dissolve) * step(fade_t - 0.12, n) * step(0.001, fade_t);

	col = mix(col, burn_color.rgb, clamp(edge * 2.2, 0.0, 1.0));

	alpha *= in_alpha;
	alpha *= mix(1.0, dissolve, step(0.001, fade_t));

	COLOR = vec4(col, alpha);
}

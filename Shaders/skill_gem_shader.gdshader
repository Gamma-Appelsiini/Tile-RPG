// =============================================================
//  SOUL GEM  —  Godot 4.7 spatial shader
//  Volumetric soul interior + refraction + iridescence + sigil
//  Author-friendly: every effect can be dialed to zero.
// =============================================================
shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

group_uniforms Shell;
uniform vec4 shell_tint : source_color = vec4(0.32, 0.05, 0.10, 1.0);
uniform float shell_opacity : hint_range(0.0, 1.0) = 0.22;
uniform float roughness : hint_range(0.0, 1.0) = 0.06;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float specular_power : hint_range(0.0, 1.0) = 0.9;
uniform sampler2D normal_map : hint_normal;
uniform float normal_strength : hint_range(0.0, 2.0) = 0.6;
uniform sampler2D flaw_map : hint_default_white; // cracks / inclusions, grayscale
uniform float flaw_strength : hint_range(0.0, 2.0) = 0.8;
uniform vec4 flaw_color : source_color = vec4(1.0, 0.45, 0.2, 1.0);

group_uniforms Refraction;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float refraction_strength : hint_range(0.0, 0.5) = 0.06;
uniform float chromatic_aberration : hint_range(0.0, 1.0) = 0.35;
uniform float refraction_blur : hint_range(0.0, 4.0) = 0.6;
uniform float ior : hint_range(1.0, 3.0) = 1.75;

group_uniforms Soul_Interior;
uniform sampler3D soul_noise : filter_linear_mipmap, repeat_enable;
uniform bool use_noise_texture = false;          // false = procedural fallback
uniform int march_steps : hint_range(8, 64) = 28;
uniform float interior_radius : hint_range(0.05, 4.0) = 0.5;
uniform vec4 soul_color_cold : source_color = vec4(0.20, 0.05, 0.45, 1.0);
uniform vec4 soul_color_hot  : source_color = vec4(1.00, 0.35, 0.10, 1.0);
uniform vec4 core_color      : source_color = vec4(1.00, 0.90, 0.70, 1.0);
uniform float density : hint_range(0.0, 4.0) = 1.4;
uniform float density_threshold : hint_range(0.0, 1.0) = 0.42;
uniform float wisp_scale : hint_range(0.2, 12.0) = 3.2;
uniform float wisp_speed : hint_range(0.0, 2.0) = 0.18;
uniform float swirl_amount : hint_range(0.0, 6.0) = 2.0;
uniform float swirl_speed : hint_range(0.0, 3.0) = 0.5;
uniform float core_intensity : hint_range(0.0, 8.0) = 2.5;
uniform float core_tightness : hint_range(1.0, 30.0) = 9.0;
uniform float interior_energy : hint_range(0.0, 8.0) = 2.0;

group_uniforms Pulse;
uniform float pulse_speed : hint_range(0.0, 6.0) = 1.1;
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.35;
uniform float heartbeat_sharpness : hint_range(1.0, 8.0) = 3.0;
uniform float charge : hint_range(0.0, 1.0) = 0.0; // drive from code on consume

group_uniforms Fresnel_Iridescence;
uniform vec4 rim_color : source_color = vec4(0.75, 0.30, 1.00, 1.0);
uniform float fresnel_power : hint_range(0.5, 8.0) = 3.2;
uniform float fresnel_strength : hint_range(0.0, 6.0) = 1.6;
uniform float iridescence_strength : hint_range(0.0, 2.0) = 0.7;
uniform float iridescence_bands : hint_range(0.5, 12.0) = 3.0;
uniform vec3 iridescence_phase = vec3(0.00, 0.33, 0.67);
uniform sampler2D iridescence_ramp : hint_default_white; // optional 1D gradient
uniform bool use_iridescence_ramp = false;

group_uniforms Sparkle;
uniform float sparkle_strength : hint_range(0.0, 4.0) = 1.0;
uniform float sparkle_scale : hint_range(1.0, 120.0) = 34.0;
uniform float sparkle_threshold : hint_range(0.5, 1.0) = 0.86;
uniform float sparkle_speed : hint_range(0.0, 4.0) = 0.6;

group_uniforms Sigil;
uniform sampler2D sigil_texture : source_color, hint_default_black;
uniform vec4 sigil_color : source_color = vec4(1.0, 0.15, 0.10, 1.0);
uniform float sigil_strength : hint_range(0.0, 6.0) = 1.2;
uniform float sigil_size : hint_range(0.1, 4.0) = 0.9;
uniform float sigil_spin : hint_range(-3.0, 3.0) = 0.15;
uniform float sigil_view_bias : hint_range(0.0, 1.0) = 0.0; // 0 = head-on, 1 = grazing

varying vec3 v_local_pos;
varying vec3 v_local_cam;
varying vec3 v_local_normal;
varying vec3 v_world_normal;

// ---------------- noise helpers ----------------
float hash31(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

float vnoise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float n000 = hash31(i + vec3(0.0, 0.0, 0.0));
	float n100 = hash31(i + vec3(1.0, 0.0, 0.0));
	float n010 = hash31(i + vec3(0.0, 1.0, 0.0));
	float n110 = hash31(i + vec3(1.0, 1.0, 0.0));
	float n001 = hash31(i + vec3(0.0, 0.0, 1.0));
	float n101 = hash31(i + vec3(1.0, 0.0, 1.0));
	float n011 = hash31(i + vec3(0.0, 1.0, 1.0));
	float n111 = hash31(i + vec3(1.0, 1.0, 1.0));
	return mix(mix(mix(n000, n100, f.x), mix(n010, n110, f.x), f.y),
	           mix(mix(n001, n101, f.x), mix(n011, n111, f.x), f.y), f.z);
}

float sample_field(vec3 p) {
	if (use_noise_texture) {
		// 3D texture is expected tileable; two octaves for detail
		float a = texture(soul_noise, p * 0.5 + 0.5).r;
		float b = texture(soul_noise, p * 1.37 + 0.13).r;
		return a * 0.65 + b * 0.35;
	}
	float f = 0.0;
	float amp = 0.5;
	vec3 q = p;
	for (int i = 0; i < 4; i++) {
		f += vnoise(q) * amp;
		q = q * 2.03 + vec3(11.3, 7.1, 3.7);
		amp *= 0.5;
	}
	return f;
}

vec3 swirl(vec3 p, float t) {
	float r = length(p.xz);
	float a = swirl_amount * r + t * swirl_speed;
	float s = sin(a);
	float c = cos(a);
	return vec3(p.x * c - p.z * s, p.y, p.x * s + p.z * c);
}

vec3 irid_palette(float t) {
	if (use_iridescence_ramp) {
		return texture(iridescence_ramp, vec2(fract(t), 0.5)).rgb;
	}
	return 0.5 + 0.5 * cos(6.28318 * (t * iridescence_bands + iridescence_phase));
}

void vertex() {
	v_local_pos = VERTEX;
	v_local_normal = NORMAL;
	v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	mat4 inv_model = inverse(MODEL_MATRIX);
	v_local_cam = (inv_model * vec4(INV_VIEW_MATRIX[3].xyz, 1.0)).xyz;
}

void fragment() {
	float t = TIME;

	// -------- heartbeat --------
	float beat = pow(max(sin(t * pulse_speed) * 0.5 + 0.5, 0.0), heartbeat_sharpness);
	float pulse = mix(1.0, beat, pulse_amount) + charge * 1.5;

	// -------- surface normal --------
	vec3 n_tex = texture(normal_map, UV).rgb * 2.0 - 1.0;
	NORMAL_MAP = texture(normal_map, UV).rgb;
	NORMAL_MAP_DEPTH = normal_strength;

	vec3 view_dir = normalize(VIEW);
	vec3 n = normalize(NORMAL);
	float ndv = clamp(dot(n, view_dir), 0.0, 1.0);
	float fresnel = pow(1.0 - ndv, fresnel_power);

	// -------- screen-space refraction with chromatic split --------
	vec2 refr = n.xy * refraction_strength;
	float ca = chromatic_aberration * 0.01;
	vec2 base_uv = SCREEN_UV + refr * (ior - 1.0);
	vec3 behind;
	behind.r = textureLod(screen_texture, clamp(base_uv + refr * ca, vec2(0.001), vec2(0.999)), refraction_blur).r;
	behind.g = textureLod(screen_texture, clamp(base_uv, vec2(0.001), vec2(0.999)), refraction_blur).g;
	behind.b = textureLod(screen_texture, clamp(base_uv - refr * ca, vec2(0.001), vec2(0.999)), refraction_blur).b;
	behind *= shell_tint.rgb * 2.0;

	// -------- volumetric soul march (local space) --------
	vec3 ro = v_local_pos;
	vec3 view_local = normalize(v_local_pos - v_local_cam);
	// bend the ray on entry so the interior parallaxes convincingly
	vec3 rd = normalize(refract(view_local, normalize(v_local_normal), 1.0 / ior));
	if (dot(rd, rd) < 0.5) {
		rd = view_local;
	}

	float R = interior_radius;
	float b = dot(ro, rd);
	float c = dot(ro, ro) - R * R;
	float h = b * b - c;

	vec4 acc = vec4(0.0);
	float core_glow = 0.0;

	if (h > 0.0) {
		h = sqrt(h);
		float t0 = max(-b - h, 0.0);
		float t1 = -b + h;
		float seg = (t1 - t0) / float(march_steps);
		float jitter = hash31(vec3(SCREEN_UV * 1024.0, t));

		for (int i = 0; i < march_steps; i++) {
			if (acc.a > 0.98) {
				break;
			}
			float tt = t0 + (float(i) + jitter) * seg;
			vec3 p = ro + rd * tt;
			float rn = length(p) / R;

			vec3 sp = swirl(p / R, t) * wisp_scale + vec3(0.0, -t * wisp_speed * 2.0, t * wisp_speed);
			float d = sample_field(sp);
			d = smoothstep(density_threshold, 1.0, d);
			d *= (1.0 - rn * rn);            // soften toward the shell
			d *= density * seg * 8.0 * pulse;

			float heat = smoothstep(0.55, 0.0, rn);
			vec3 col = mix(soul_color_cold.rgb, soul_color_hot.rgb, heat);

			acc.rgb += col * d * (1.0 - acc.a);
			acc.a += d * (1.0 - acc.a);

			core_glow += exp(-length(p) * core_tightness) * seg * (1.0 - acc.a * 0.5);
		}
	}

	vec3 interior = acc.rgb * interior_energy;
	interior += core_color.rgb * core_glow * core_intensity * pulse;

	// -------- camera-facing sigil card inside the gem --------
	vec3 fwd = view_local;
	vec3 up = abs(fwd.y) > 0.95 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
	vec3 right = normalize(cross(up, fwd));
	up = cross(fwd, right);
	float sa = t * sigil_spin;
	vec2 suv = vec2(dot(v_local_pos, right), dot(v_local_pos, up)) / max(sigil_size, 0.001);
	suv = mat2(vec2(cos(sa), -sin(sa)), vec2(sin(sa), cos(sa))) * suv + 0.5;
	vec3 sigil = texture(sigil_texture, clamp(suv, 0.0, 1.0)).rgb * sigil_color.rgb;
	float sigil_view = mix(ndv, 1.0 - ndv, sigil_view_bias);
	interior += sigil * sigil_strength * pow(sigil_view, 2.0) * pulse * (1.0 - acc.a * 0.6);

	// -------- iridescence, driven purely by view angle --------
	vec3 irid = irid_palette(1.0 - ndv) * iridescence_strength * fresnel;

	// -------- facet sparkle, local space so it swims as you orbit --------
	vec3 sp_pos = v_local_pos * sparkle_scale + v_local_normal * 3.0;
	float sp_n = vnoise(sp_pos + vec3(0.0, t * sparkle_speed, 0.0));
	float sparkle = smoothstep(sparkle_threshold, 1.0, sp_n) * sparkle_strength;
	sparkle *= mix(0.25, 1.0, fresnel);

	// -------- cracks / inclusions --------
	float flaw = texture(flaw_map, UV).r;
	vec3 flaw_emit = flaw_color.rgb * pow(flaw, 2.0) * flaw_strength * pulse * (0.4 + charge);

	// -------- composite --------
	vec3 base = mix(behind, shell_tint.rgb, shell_opacity);
	ALBEDO = base;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular_power;

	EMISSION = interior
	         + irid
	         + rim_color.rgb * fresnel * fresnel_strength * pulse
	         + vec3(sparkle)
	         + flaw_emit;

	EMISSION *= 1.0 + charge * 3.0;

	ALPHA = clamp(shell_opacity + acc.a * 0.6 + fresnel * 0.6, 0.0, 1.0);
	ALPHA = mix(ALPHA, 1.0, 0.35); // keep the gem readable against bright scenes
}

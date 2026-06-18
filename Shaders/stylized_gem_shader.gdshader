shader_type spatial;
render_mode unshaded, cull_back;

// ---------------- Base look ----------------
uniform vec4 base_color : source_color = vec4(0.02, 0.06, 0.28, 1.0); // deep navy face color
uniform vec4 edge_color : source_color = vec4(0.55, 0.95, 1.0, 1.0);  // bright cyan facet lines

// ---------------- Facet edge lines ----------------
// Detected from a jump in the surface normal between adjacent facets.
// Works best when the mesh normals are "smooth inside a facet, split at the
// real edges" (see notes below the shader).
uniform float edge_thickness : hint_range(0.0, 10.0) = 3.0;
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.12;
uniform float edge_softness  : hint_range(0.0, 1.0) = 0.08;
uniform float edge_glow      : hint_range(0.0, 5.0) = 2.0;

// ---------------- Silhouette rim ----------------
// A second, always-reliable edge highlight along the outer silhouette,
// in case the mesh uses fully flat normals (no internal jump to detect).
uniform float rim_power    : hint_range(0.1, 16.0) = 6.0;
uniform float rim_strength : hint_range(0.0, 3.0) = 0.6;

// ---------------- Iridescent / rainbow gradient ----------------
uniform float fresnel_power        : hint_range(0.1, 8.0) = 2.5;
uniform float iridescence_strength : hint_range(0.0, 2.0) = 1.0;
uniform float iridescence_scale    : hint_range(0.1, 10.0) = 3.0;
uniform float iridescence_shift    : hint_range(0.0, 6.2832) = 0.0;
uniform float time_speed           : hint_range(0.0, 2.0) = 0.0; // 0 = static, like the reference

// ---------------- Fake specular sparkle ----------------
uniform vec4 spec_color_1 : source_color = vec4(1.0, 0.85, 0.55, 1.0);
uniform vec4 spec_color_2 : source_color = vec4(0.55, 0.8, 1.0, 1.0);
uniform vec3 light_dir_1 = vec3(0.4, 0.85, 0.3);
uniform vec3 light_dir_2 = vec3(-0.6, 0.3, -0.5);
uniform float specular_sharpness : hint_range(1.0, 256.0) = 48.0;
uniform float specular_strength  : hint_range(0.0, 5.0) = 1.2;

varying vec3 world_normal;
varying vec3 world_pos;

void vertex() {
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Cosine-based color palette (cheap way to get smooth rainbow hues)
vec3 palette(float t) {
	vec3 a = vec3(0.45, 0.45, 0.50);
	vec3 b = vec3(0.50, 0.45, 0.55);
	vec3 c = vec3(1.00, 1.00, 1.00);
	vec3 d = vec3(0.30, 0.55, 0.75);
	return a + b * cos(6.28318 * (c * t + d));
}

void fragment() {
	vec3 N = normalize(world_normal);
	vec3 V = normalize(CAMERA_POSITION_WORLD - world_pos);
	float ndotv = clamp(dot(N, V), 0.0, 1.0);

	float fres = pow(1.0 - ndotv, fresnel_power);
	float rim  = pow(1.0 - ndotv, rim_power) * rim_strength;

	// Rainbow gradient. The facet-direction term makes each face lean
	// toward a different hue, just like the reference gems.
	float t = fres * iridescence_scale
			+ dot(N, vec3(0.3, 1.0, 0.15)) * 1.5
			+ TIME * time_speed
			+ iridescence_shift;
	vec3 rainbow = palette(t);

	vec3 col = mix(base_color.rgb, rainbow, clamp(fres * iridescence_strength + 0.12, 0.0, 1.0));

	// Fake specular hot-spots (two tinted "lights")
	vec3 R = reflect(-V, N);
	float s1 = pow(max(dot(R, normalize(light_dir_1)), 0.0), specular_sharpness);
	float s2 = pow(max(dot(R, normalize(light_dir_2)), 0.0), specular_sharpness);
	col += s1 * spec_color_1.rgb * specular_strength;
	col += s2 * spec_color_2.rgb * specular_strength;

	// Crisp facet edge lines from normal discontinuity
	vec3 nd = fwidth(N);
	float edge_raw = (nd.x + nd.y + nd.z) * edge_thickness;
	float edge = smoothstep(edge_threshold, edge_threshold + edge_softness, edge_raw);
	edge = max(edge, rim);

	col = mix(col, edge_color.rgb, edge);

	ALBEDO = col;
	EMISSION = edge_color.rgb * edge * edge_glow + rainbow * fres * 0.15;
}

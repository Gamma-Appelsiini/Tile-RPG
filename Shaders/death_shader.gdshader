shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
// ═══════════════════════════════════════════════════════════════
//  DEATH OVERLAY SHADER  ·  Dark Fantasy RPG  ·  Godot 4.5
//
//  Setup:
//    1. ColorRect (Full Rect anchor) on a CanvasLayer above game.
//    2. Assign a ShaderMaterial with this shader.
//    3. In the Inspector, assign two noise textures:
//         noise_warp  — NoiseTexture2D, Simplex/Perlin, seamless ON
//                       Suggested: width=512, height=512
//         noise_bleed — NoiseTexture2D, different seed, seamless ON
//                       Suggested: width=256, height=256, higher frequency
//    4. Tween `strength` 0.0 → 1.0 on player death.
// ═══════════════════════════════════════════════════════════════

render_mode unshaded;

// ── Master ────────────────────────────────────────────────────
uniform float strength            : hint_range(0.0, 1.0) = 0.0;

// ── Noise Textures ────────────────────────────────────────────
uniform sampler2D noise_warp  : hint_default_black, repeat_enable;
// Primary warp: large rolling waves that bend the whole world.
// Use a low-frequency seamless Perlin/Simplex noise.

uniform sampler2D noise_bleed : hint_default_black, repeat_enable;
// Secondary bleed: used for chromatic splitting and luma erosion.
// Use a higher-frequency noise than noise_warp.

// ── Primary UV Warp ───────────────────────────────────────────
uniform float warp_amount         : hint_range(0.0, 0.12) = 0.045;
// Max UV displacement. 0.04–0.06 is sickening; above 0.08 is surreal.
uniform float warp_speed          : hint_range(0.0, 2.0)  = 0.28;
// How fast the warp slowly churns. Keep low — death is heavy, not jittery.
uniform float warp_scale          : hint_range(0.1, 4.0)  = 0.55;
// UV tiling of the warp noise. Lower = bigger, lazier rolls.
uniform float warp_octave_blend   : hint_range(0.0, 1.0)  = 0.40;
// Blends in a second, faster warp sample for detail on top of the base roll.

// ── Chromatic Bleed ───────────────────────────────────────────
uniform float chroma_amount       : hint_range(0.0, 0.04) = 0.018;
// How far the R/B channels split from G. Noise-driven, not radial.
// This makes it feel like the eye is failing, not like a lens.
uniform float chroma_speed        : hint_range(0.0, 2.0)  = 0.42;
uniform float chroma_scale        : hint_range(0.1, 6.0)  = 1.8;

// ── Luma Erosion ──────────────────────────────────────────────
uniform float erosion_strength    : hint_range(0.0, 1.0)  = 0.55;
// The noise darkens bright areas unevenly — like shadows eating the image.
uniform float erosion_speed       : hint_range(0.0, 2.0)  = 0.18;
uniform float erosion_scale       : hint_range(0.1, 4.0)  = 0.80;
uniform float erosion_contrast    : hint_range(1.0, 8.0)  = 3.5;
// Sharpens the erosion mask — higher = harder, patchier dark blobs.

// ── Desaturation ──────────────────────────────────────────────
uniform float desaturation        : hint_range(0.0, 1.0) = 1.0;

// ── Contrast crush ────────────────────────────────────────────
uniform float contrast_crush      : hint_range(0.0, 1.0) = 0.48;

// ── Death tint ────────────────────────────────────────────────
uniform vec4  death_tint          : source_color = vec4(0.07, 0.04, 0.11, 1.0);
uniform float tint_strength       : hint_range(0.0, 1.0) = 0.38;

// ── Vignette ──────────────────────────────────────────────────
uniform float vignette_intensity  : hint_range(0.0, 5.0)  = 2.5;
uniform float vignette_sharpness  : hint_range(0.5, 10.0) = 4.2;

// ── Film grain ────────────────────────────────────────────────
uniform float grain_strength      : hint_range(0.0, 1.0) = 0.22;

// ── Final darkening ───────────────────────────────────────────
uniform float darkness_floor      : hint_range(0.0, 1.0) = 0.12;


// ═══════════════════════════════════════════════════════════════
//  UTILITY
// ═══════════════════════════════════════════════════════════════

float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

float hash21(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 19.19);
	return fract(p.x * p.y);
}

// Smoothstep ease — effect stays subtle until ~50%, then accelerates.
float ease_in(float x) {
	return x * x * (3.0 - 2.0 * x);
}

// Sample noise texture and remap 0..1 → -1..1
vec2 noise_vec2(sampler2D tex, vec2 uv) {
	// Sample two slightly offset UVs to get an independent X and Y.
	// This avoids the diagonal bias you get from using R/G channels of one sample.
	float nx = texture(tex, uv).r;
	float ny = texture(tex, uv + vec2(0.4, 0.7)).r;
	return (vec2(nx, ny) - 0.5) * 2.0;
}


// ═══════════════════════════════════════════════════════════════
//  FRAGMENT
// ═══════════════════════════════════════════════════════════════
void fragment() {
	float s = strength;

	if (s <= 0.001) {
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	}

	float se = ease_in(s);  // eased strength for displacement effects
	float t  = TIME;

	// ── 1. PRIMARY UV WARP ────────────────────────────────────
	// Two noise samples at different speeds/offsets, blended together.
	// This gives the layered, organic crawl of a dying vision.

	vec2 warp_uv_a = SCREEN_UV * warp_scale + vec2(t * warp_speed * 0.7, t * warp_speed * 0.5);
	vec2 warp_uv_b = SCREEN_UV * warp_scale * 1.7 + vec2(t * warp_speed * -0.4, t * warp_speed * 0.9)
	                 + vec2(0.31, 0.57); // phase offset so B isn't just a scaled A

	vec2 warp_a = noise_vec2(noise_warp, warp_uv_a);
	vec2 warp_b = noise_vec2(noise_warp, warp_uv_b);
	vec2 warp   = mix(warp_a, warp_b, warp_octave_blend);

	vec2 warped_uv = clamp(SCREEN_UV + warp * warp_amount * se, vec2(0.001), vec2(0.999));

	// ── 2. CHROMATIC BLEED ────────────────────────────────────
	// R and B channels are displaced independently, driven by noise.
	// Unlike radial chroma aberration, this one pulses and breathes —
	// like a signal losing coherence, not a lens flaw.

	vec2 chroma_uv = SCREEN_UV * chroma_scale + vec2(t * chroma_speed * 0.6, t * chroma_speed * 0.3);
	vec2 chroma_dir = noise_vec2(noise_bleed, chroma_uv);

	float chroma_mag = chroma_amount * se;
	vec2 uv_r = clamp(warped_uv + chroma_dir * chroma_mag,          vec2(0.001), vec2(0.999));
	vec2 uv_g = warped_uv; // green stays anchored
	vec2 uv_b = clamp(warped_uv - chroma_dir * chroma_mag * 0.75,  vec2(0.001), vec2(0.999));

	float r = texture(SCREEN_TEXTURE, uv_r).r;
	float g = texture(SCREEN_TEXTURE, uv_g).g;
	float b = texture(SCREEN_TEXTURE, uv_b).b;
	vec3 col = vec3(r, g, b);

	// ── 3. LUMA EROSION ───────────────────────────────────────
	// A slow-drifting noise mask darkens patches of the image unevenly,
	// as though shadows are physically consuming the world.
	// Brighter areas erode first — the light dies before the dark.

	vec2 erosion_uv = SCREEN_UV * erosion_scale + vec2(t * erosion_speed * 0.5, t * erosion_speed * 0.3);
	float erosion_noise = texture(noise_bleed, erosion_uv).r;

	// Power sharpens the mask into harder dark blobs
	float erosion_mask = pow(erosion_noise, erosion_contrast);

	// Modulate by luminance — bright pixels erode more
	float pixel_luma = luma(col);
	float erosion_factor = erosion_mask * pixel_luma;

	col = mix(col, col * (1.0 - erosion_factor), erosion_strength * se);

	// ── 4. FILM GRAIN ─────────────────────────────────────────
	vec2 grain_uv = SCREEN_UV * 900.0 + vec2(floor(t * 18.0 * warp_speed + 1.0),
	                                          floor(t * 14.0 * warp_speed + 1.0));
	float grain = (hash21(grain_uv) - 0.5) * 2.0;
	col += grain * grain_strength * s;

	// ── 5. CONTRAST CRUSH ─────────────────────────────────────
	col = mix(col, vec3(0.40), contrast_crush * s);

	// ── 6. DESATURATION ───────────────────────────────────────
	col = mix(col, vec3(luma(col)), desaturation * s);

	// ── 7. DEATH TINT ─────────────────────────────────────────
	col = mix(col, col * death_tint.rgb * 2.0, tint_strength * s);

	// ── 8. VIGNETTE ───────────────────────────────────────────
	vec2 vig_uv = SCREEN_UV * (1.0 - SCREEN_UV.yx);
	float vig = pow(clamp(vig_uv.x * vig_uv.y * vignette_intensity * 16.0, 0.0, 1.0),
	                vignette_sharpness);
	col *= mix(1.0, vig, s);

	// ── 9. GLOBAL DARKENING ───────────────────────────────────
	col *= mix(1.0, darkness_floor, s);

	COLOR = vec4(clamp(col, 0.0, 1.0), 1.0);
}

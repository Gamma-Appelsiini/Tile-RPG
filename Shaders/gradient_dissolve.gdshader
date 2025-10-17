shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_disabled, diffuse_lambert, specular_schlick_ggx, unshaded, shadows_disabled;

uniform vec4 ColorParameter : source_color;
uniform vec2 moveAmount;
uniform sampler2D noiseTexture : source_color;
uniform sampler2D maskTexture : source_color;

void fragment() {
// ColorParameter:12
	vec4 n_out12p0 = ColorParameter;

// Input:7
	float n_out7p0 = TIME;

// Vector2Parameter:8
	vec2 n_out8p0 = moveAmount;

// UVFunc:3
	vec2 n_out3p0 = n_out8p0 * vec2(n_out7p0) + UV;

	vec4 n_out4p0;
// Texture2D:4
	n_out4p0 = texture(noiseTexture, n_out3p0);
	float n_out4p1 = n_out4p0.r;

// Texture2D:2
	vec4 n_out2p0 = texture(maskTexture, UV);
	float n_out2p1 = n_out2p0.r;

// FloatOp:9
	float n_out9p0 = n_out4p1 * n_out2p1;

// Output:0
	ALBEDO = vec3(n_out12p0.xyz);
	ALPHA = n_out9p0;

}
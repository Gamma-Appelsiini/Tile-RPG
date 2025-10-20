shader_type spatial;
render_mode blend_mix, depth_draw_opaque, depth_test_default, cull_disabled, diffuse_lambert, specular_schlick_ggx, unshaded, shadows_disabled;

uniform vec2 speed;
uniform sampler2D aura_texture : source_color;
uniform sampler2D maskTexture : source_color;
uniform float ProxFade;
uniform sampler2D depth_tex_frg_13 : hint_depth_texture;
uniform vec4 ColorParameter : source_color;


void fragment() {
// Input:3
	vec4 n_out3p0 = ColorParameter;
	float n_out3p4 = n_out3p0.a;


// Input:8
	float n_out8p0 = TIME;


// Vector2Parameter:9
	vec2 n_out9p0 = speed;


// VectorOp:10
	vec2 n_out10p0 = vec2(n_out8p0) * n_out9p0;


// UVFunc:7
	vec2 n_in7p1 = vec2(1.00000, 1.00000);
	vec2 n_out7p0 = n_out10p0 * n_in7p1 + UV;


	vec4 n_out12p0;
// Texture2D:12
	n_out12p0 = texture(aura_texture, n_out7p0);


// Texture2D:2
	vec4 n_out2p0 = texture(maskTexture, UV);
	float n_out2p1 = n_out2p0.r;


// FloatOp:6
	float n_out6p0 = n_out12p0.x * n_out2p1;


// FloatOp:4
	float n_out4p0 = n_out3p4 * n_out6p0;


// FloatParameter:15
	float n_out15p0 = ProxFade;


	float n_out13p0;
// ProximityFade:13
	{
		float __depth_tex = texture(depth_tex_frg_13, SCREEN_UV).r;
		vec4 __depth_world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, __depth_tex, 1.0);
		__depth_world_pos.xyz /= __depth_world_pos.w;
		n_out13p0 = clamp(1.0 - smoothstep(__depth_world_pos.z + n_out15p0, __depth_world_pos.z, VERTEX.z), 0.0, 1.0);
	}


// FloatOp:14
	float n_out14p0 = n_out4p0 * n_out13p0;


// Output:0
	ALBEDO = vec3(n_out3p0.xyz);
	ALPHA = n_out14p0;


}
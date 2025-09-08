shader_type spatial;
render_mode cull_back, depth_draw_opaque, unshaded;

uniform float liquid_amount : hint_range(-0.5, 1.5) = 1.0; // Fill percent
uniform float wave_strength : hint_range(0.0, 1.0) = 0.2; // Wave strength
uniform vec3 liquid_color : source_color = vec3(1.0, 0.0, 0.0); // Base color

// Noise textures
uniform sampler2D noise_tex1 : source_color;
uniform sampler2D noise_tex2 : source_color;

// Noise UV controls
uniform float noise_scale : hint_range(0.1, 5.0) = 1.5;
uniform vec2 noise1_speed = vec2(0.2, 0.0);
uniform vec2 noise2_speed = vec2(-0.15, 0.1);

// Noise appearance controls
uniform float noise_intensity : hint_range(0.0, 2.0) = 0.5; // How strong the noise affects color
uniform vec3 noise_color : source_color = vec3(1.0, 0.5, 0.5); // Tint applied to noise
uniform float noise_contrast : hint_range(0.5, 3.0) = 1.0; // Sharpen / flatten noise

// Fresnel controls
uniform float fresnel_strength : hint_range(0.0, 3.0) = 1.0;
uniform float fresnel_power : hint_range(0.5, 8.0) = 3.0;
uniform vec3 fresnel_color : source_color = vec3(1.0, 0.2, 0.2);

varying vec3 local_pos;
varying vec2 uv_coords;

void vertex() {
    local_pos = VERTEX;
    uv_coords = UV;
}

void fragment() {
    // Y position normalized to [0,1]
    float height = local_pos.y + 0.5;

    // Wavy surface
    float wave = sin(local_pos.x * 5.0 + TIME * 2.0)
               + cos(local_pos.z * 5.0 + TIME * 1.5);
    wave *= 0.05 * wave_strength;

    float surface = liquid_amount + wave;

    if (height < surface) {
        // Animate noise sampling
        vec2 uv1 = uv_coords * noise_scale + noise1_speed * TIME;
        vec2 uv2 = uv_coords * noise_scale + noise2_speed * TIME;

        float n1 = texture(noise_tex1, uv1).r;
        float n2 = texture(noise_tex2, uv2).r;

        // Combine & contrast
        float swirl = (n1 * 0.6 + n2 * 0.4);
        swirl = pow(swirl, noise_contrast);

        // Base liquid color
        vec3 base = liquid_color;
        vec3 swirl_col = mix(base, noise_color, swirl * noise_intensity);

        // Fresnel term (rim highlight)
        float fresnel = 1.0 - abs(dot(NORMAL, VIEW));
        fresnel = pow(fresnel, fresnel_power) * fresnel_strength;

        // Blend Fresnel color
        vec3 final_col = swirl_col + fresnel * fresnel_color;

        ALBEDO = final_col;
    } else {
        discard;
    }
}
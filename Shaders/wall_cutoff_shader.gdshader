shader_type spatial;
render_mode cull_disabled;

group_uniforms BaseMaterial;
uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0) = 1.0;
uniform vec4 emission : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform sampler2D texture_emission : source_color, filter_linear_mipmap, repeat_enable;
uniform float emission_energy : hint_range(0.0, 100.0) = 1.0;

group_uniforms IsometricCutoff;
uniform float local_height = 2.5;
uniform sampler2D noise_texture : hint_default_black, filter_linear_mipmap, repeat_enable;
uniform float noise_scale = 1.0;
uniform float noise_amplitude = 0.0;
uniform vec2 noise_speed = vec2(0.2, 0.2);

varying vec3 local_pos;

void vertex() {
    local_pos = VERTEX;
}

void fragment() {
    vec2 noise_uv = (local_pos.xz * noise_scale) + (noise_speed * TIME);
    float noise_val = texture(noise_texture, noise_uv).r;
    
    float height_offset = (noise_val - 0.5) * noise_amplitude;
    float current_cutoff = local_height + height_offset;

    if (local_pos.y > current_cutoff) {
        discard;
    }

    if (!FRONT_FACING) {
        ALBEDO = vec3(0.0);
        EMISSION = vec3(0.0);
        SPECULAR = 0.0;
        ROUGHNESS = 1.0;
        METALLIC = 0.0;
    } else {
        vec4 albedo_tex = texture(texture_albedo, UV);
        ALBEDO = albedo.rgb * albedo_tex.rgb;
        
        float metallic_tex = texture(texture_metallic, UV).r;
        METALLIC = metallic * metallic_tex;
        
        float roughness_tex = texture(texture_roughness, UV).r;
        ROUGHNESS = roughness * roughness_tex;
        
        NORMAL_MAP = texture(texture_normal, UV).rgb;
        NORMAL_MAP_DEPTH = normal_scale;
        
        vec3 emission_tex = texture(texture_emission, UV).rgb;
        EMISSION = (emission.rgb + emission_tex) * emission_energy;
    }
}
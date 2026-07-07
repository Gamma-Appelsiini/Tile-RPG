shader_type canvas_item;
render_mode blend_mix;

// --- Uniforms ---
group_uniforms Base_Look;
uniform sampler2D gradient_texture : source_color, filter_linear;
uniform float gradient_intensity : hint_range(0.0, 2.0) = 1.0;

group_uniforms Outline_And_Shadow;
uniform vec4 outline_color : source_color = vec4(0.12, 0.08, 0.08, 1.0); // Dark iron/crusty blood
uniform float outline_width : hint_range(0.0, 10.0) = 2.5;
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.8);
uniform vec2 shadow_offset = vec2(3.0, 4.0);

group_uniforms Text_Juice;
uniform float shine_speed : hint_range(0.0, 5.0) = 1.5;
uniform float shine_width : hint_range(0.05, 0.5) = 0.15;
uniform vec4 shine_color : source_color = vec4(1.0, 0.9, 0.7, 0.4); // Metallic glint

group_uniforms Critical_Hit;
uniform bool is_crit = false;
uniform float crit_pulse_speed : hint_range(1.0, 20.0) = 10.0;
uniform vec4 crit_aura_color : source_color = vec4(0.9, 0.2, 0.0, 1.0); // Demonic orange/red
uniform float crit_shake_intensity : hint_range(0.0, 10.0) = 2.5;

// --- Vertex Shader ---
void vertex() {
	if (is_crit) {
		// Violent, satisfying dark fantasy shake effect for crits
		float time_scale = TIME * crit_pulse_speed;
		VERTEX.x += sin(time_scale * 1.5 + VERTEX.y) * crit_shake_intensity;
		VERTEX.y += cos(time_scale * 1.3 + VERTEX.x) * crit_shake_intensity;
		
		// Pulsate the size slightly over time
		float pulse = 1.0 + sin(time_scale) * 0.08;
		VERTEX *= pulse;
	}
}

// --- Fragment Shader ---
void fragment() {
	vec2 uv = UV;
	vec4 text_color = texture(TEXTURE, uv);
	
	// 1. Text Gradient Tinting
	vec4 sampled_gradient = texture(gradient_texture, vec2(uv.y, 0.5));
	vec4 base_text = text_color * sampled_gradient * gradient_intensity;
	
	// 2. Juicy Moving Metallic Shine Line
	float shine_cycle = fract(TIME * shine_speed * 0.25);
	// Slanted line function across the UV space
	float line_pos = uv.x * 0.5 + uv.y * 0.5; 
	float shine_factor = smoothstep(shine_cycle - shine_width, shine_cycle, line_pos) * smoothstep(shine_cycle + shine_width, shine_cycle, line_pos);
	
	vec4 final_text = base_text + (shine_color * shine_factor * text_color.a);
	
	// 3. Chiseled Bevel / Inner Shadow (Dark Fantasy Grit)
	float lower_neighbor = texture(TEXTURE, uv + vec2(0.0, TEXTURE_PIXEL_SIZE.y * 2.0)).a;
	if (text_color.a > 0.0 && lower_neighbor < 1.0) {
		final_text.rgb *= 0.5; // Darken bottom edges for a carved 3D look
	}

	// 4. Outline and Drop Shadow Calculations
	float outline_alpha = 0.0;
	float shadow_alpha = 0.0;
	vec2 outline_size = TEXTURE_PIXEL_SIZE * outline_width;
	vec2 shadow_size = TEXTURE_PIXEL_SIZE * (outline_width + shadow_offset);

	// 8-Directional Sampling for clean thickness
	for(float x = -1.0; x <= 1.0; x += 1.0) {
		for(float y = -1.0; y <= 1.0; y += 1.0) {
			if(x == 0.0 && y == 0.0) continue;
			
			vec2 dir = normalize(vec2(x, y));
			outline_alpha += texture(TEXTURE, uv + dir * outline_size).a;
			shadow_alpha += texture(TEXTURE, uv + (dir * outline_size) + (TEXTURE_PIXEL_SIZE * shadow_offset)).a;
		}
	}
	outline_alpha = clamp(outline_alpha, 0.0, 1.0);
	shadow_alpha = clamp(shadow_alpha, 0.0, 1.0);

	// 5. Critical Hit Hellfire Aura
	vec4 aura = vec4(0.0);
	if (is_crit) {
		float wave = sin(TIME * crit_pulse_speed + uv.x * 20.0) * 0.5 + 0.5;
		float aura_thick = outline_width * (2.0 + wave * 1.5);
		float aura_alpha = 0.0;
		
		for(float x = -1.0; x <= 1.0; x += 2.0) {
			for(float y = -1.0; y <= 1.0; y += 2.0) {
				aura_alpha += texture(TEXTURE, uv + vec2(x, y) * TEXTURE_PIXEL_SIZE * aura_thick).a;
			}
		}
		aura = crit_aura_color * clamp(aura_alpha, 0.0, 1.0) * (0.4 + wave * 0.6);
	}

	// 6. Layer Composition (Back to Front)
	vec4 composite_color = vec4(0.0);
	
	// Drop Shadow
	composite_color = mix(composite_color, shadow_color, shadow_alpha * shadow_color.a);
	
	// Crit Aura
	if (is_crit) {
		composite_color = mix(composite_color, aura, aura.a);
	}
	
	// Heavy Outline
	composite_color = mix(composite_color, outline_color, outline_alpha);
	
	// Core Text + Shine
	composite_color = mix(composite_color, final_text, text_color.a);
	
	// Overdrive text brightness during crits
	if (is_crit && text_color.a > 0.0) {
		composite_color.rgb += vec3(0.3, 0.1, 0.0) * (sin(TIME * crit_pulse_speed) * 0.5 + 0.5);
	}

	COLOR = composite_color;
}
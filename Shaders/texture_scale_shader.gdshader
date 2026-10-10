shader_type canvas_item;

// Adjust this value to scale your tiling texture
uniform float tiling_scale : hint_range(0.1, 20.0) = 2.0;

// Declare a varying variable to pass the modulate color down
varying vec4 vertex_color;

void vertex() {
    // Capture the node's modulate / self_modulate color passed from Godot
    vertex_color = COLOR;
}

void fragment() {
    // Scale the UV coordinates for tiling
    vec2 scaled_uv = UV * tiling_scale;
    
    // Sample the texture and multiply it by the node's modulate color
    COLOR = texture(TEXTURE, scaled_uv) * vertex_color;
}
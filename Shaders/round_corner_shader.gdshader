shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.1;
uniform float edge_softness : hint_range(0.0, 1.0) = 0.005;

void fragment() {
    // Standard UVs are 0,0 to 1,1
    vec2 size = vec2(1.0);
    vec2 p = UV;
    
    // Create Rounded Rectangle Mask
    vec2 edge_dist = min(p, 1.0 - p);
    vec2 corner_pos = min(edge_dist, radius);
    float dist = length(max(vec2(0.0) - min(edge_dist - radius, 0.0), 0.0));
    
    // Smoothstep for anti-aliasing
    float alpha = 1.0 - smoothstep(radius - edge_softness, radius + edge_softness, dist);
    
    // Apply to texture
    vec4 tex = texture(TEXTURE, UV);
    COLOR = vec4(tex.rgb, tex.a * alpha);
}

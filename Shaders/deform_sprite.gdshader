shader_type canvas_item;
uniform float deformation_amount : hint_range(-1.0, 1.0) = 0.0;

void vertex() {
    // Deform vertices along the X-axis based on uniform
    //VERTEX.x += VERTEX.y * deformation_amount;
    //float mask = VERTEX.y * 1.0; 
    //VERTEX.y -= 0.1*mask; // Quadratic falloff
}
shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 0.2, 0.001) = 0.05;
uniform float speed : hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float bend_curve : hint_range(0.5, 4.0, 0.1) = 2.0;

void fragment() {
	float bend_weight = pow(1.0 - UV.y, bend_curve);

	float offset = sin(TIME * speed) * amplitude * bend_weight;
	vec2 uv = UV + vec2(offset, 0.0);

	COLOR = texture(TEXTURE, uv);
}
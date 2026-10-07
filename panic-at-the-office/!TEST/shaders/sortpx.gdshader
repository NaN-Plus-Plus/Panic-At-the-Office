shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float mask_softness = 1.4;
uniform float mask_threshold = 0.6;
uniform float sort : hint_range(0.0, 2.0) = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 tex = texture(SCREEN_TEXTURE, uv);

	float f = mask_softness / 2.0;
	float a = mask_threshold - f;
	float b = mask_threshold + f;
	float average = (tex.r + tex.g + tex.b) / 3.0;
	float mask = smoothstep(a, b, average);

	float sort_threshold = 1.0 - clamp(sort / 2.6, 0.0, 1.0);
	vec2 sort_uv = vec2(uv.x, sort_threshold);

	vec2 transition_uv = uv;
	float turbulance = fract(sin(dot(vec2(transition_uv.x), vec2(12.9, 78.2))) * 437.5);
	transition_uv.y += pow(sort, 2.0 + (sort * 2.0)) * mask * turbulance;

	if (transition_uv.y > 1.0) {
		COLOR = texture(SCREEN_TEXTURE, sort_uv);
	} else {
		COLOR = texture(SCREEN_TEXTURE, uv);
	}
}
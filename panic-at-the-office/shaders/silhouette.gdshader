shader_type canvas_item;

uniform vec4 silhouette_color : source_color = vec4(1, 0.75, 0, 0.4);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 sprite_color = texture(TEXTURE, UV);
	
	if (all(lessThan(abs(sprite_color - screen_color), vec4(0.1)))) {
		COLOR = sprite_color;
	} else if (sprite_color == vec4(0, 0, 0, 1)) {
		COLOR = vec4(0, 0, 0, silhouette_color.a);
	} else {
		COLOR = vec4(silhouette_color.rgb, silhouette_color.a * sprite_color.a);
	}
}

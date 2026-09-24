shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float radius : hint_range(0.0, 1.0) = 1.0;
uniform float softness : hint_range(0.01, 1.0) = 0.35;

void fragment() {
    vec4 scene = texture(screen_texture, SCREEN_UV);

    vec2 centered_uv = SCREEN_UV - vec2(0.5);
    float distance_from_center = length(centered_uv) * 2.0;

    float vignette = smoothstep(
        radius * 1.5 - softness,
        radius * 1.5 + softness,
        distance_from_center
    );

    scene.rgb *= 1.0 - vignette * strength;
    COLOR = scene;
}
shader_type canvas_item;

#define iTime TIME

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform bool curvature = true;
uniform bool mask = true;
uniform bool scan_line = true;
uniform bool transparency = false;
uniform bool mode2 = false;
uniform vec4 trim_color = vec4(1.0);

vec2 CRTCurveUV( vec2 uv )
{
    uv = uv * 2.0 - 1.0;
    vec2 offset = abs( uv.yx ) / vec2( 6.0, 4.0 );
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

void DrawVignette( inout vec3 color, vec2 uv )
{    
    float vignette = uv.x * uv.y * ( 1.0 - uv.x ) * ( 1.0 - uv.y );
    vignette = clamp( pow( 16.0 * vignette, 0.3 ), 0.0, 1.0 );
    color *= vignette;
}

void DrawScanline( inout vec3 color, vec2 uv )
{
    float scanline 	= clamp( 0.95 + 0.05 * cos( 3.14 * ( uv.y + 0.008 * iTime ) * 240.0 * 1.0 ), 0.0, 1.0 );
    float grille 	= 0.85 + 0.15 * clamp( 1.5 * cos( 3.14 * uv.x * 640.0 * 1.0 ), 0.0, 1.0 );    
    color *= scanline * grille * 1.2;
}

void fragment()
{
    vec2 uv = SCREEN_UV;
    vec2 crtUV = CRTCurveUV( uv );

	vec4 col1 = texture(screen_texture, curvature ? crtUV : SCREEN_UV);
	vec3 color = col1.rgb;

	if (curvature == true){
		if ( crtUV.x < 0.0 || crtUV.x > 1.0 || crtUV.y < 0.0 || crtUV.y > 1.0 )
		{
			color = vec3( 0.0, 0.0, 0.0 );
		}
	}
	if (mask == true){
		DrawVignette( color, uv );
	}
    if (scan_line == true)
    {
		DrawScanline( color, uv );
	}

	COLOR = vec4(color, 1.0);
	if (transparency == true){
		COLOR.a = color.r;
	}

	COLOR = vec4(COLOR.r * trim_color.r, COLOR.g * trim_color.g, COLOR.b * trim_color.b, COLOR.a * trim_color.a);
}
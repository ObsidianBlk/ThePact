shader_type canvas_item;

uniform float texture_scale = 1.0;
uniform bool preserve_alpha = true;
uniform sampler2D textureA;
uniform sampler2D textureB;
uniform sampler2D textureC;
uniform sampler2D textureD;

float map_to_1(float value, float minval, float maxval){
	float range = maxval - minval;
	return max(0.0, min(1.0, (value - minval) / range));
}

vec4 calculate_color(vec4 base, vec2 uv){
	float cPixel = base.r * 255.0;
	vec2 uv2 = mod(uv * texture_scale, 1.0);
	if (cPixel >= 0.0 && cPixel < 85.0){
		float weight = map_to_1(cPixel, 0.0, 85.0);
		return mix(texture(textureA, uv2), texture(textureB, uv2), weight);
	} else if (cPixel >= 85.0 && cPixel < 168.0){
		float weight = map_to_1(cPixel, 85.0, 168.0);
		return mix(texture(textureB, uv2), texture(textureC, uv2), weight);
	} else if (cPixel >= 168.0 && cPixel <= 255.0){
		float weight = map_to_1(cPixel, 168.0, 255.0);
		return mix(texture(textureC, uv2), texture(textureD, uv2), weight);
	}
	return vec4(1.0, 0.0, 0.0, 1.0);
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float a = color.a;
	color = calculate_color(color, UV);
	if (preserve_alpha){
		color.a = a;
	}
	COLOR = color;
}

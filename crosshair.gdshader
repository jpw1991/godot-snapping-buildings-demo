shader_type canvas_item;

uniform bool snap = false;

void fragment()
{
	vec2 uv = UV - 0.5;
	float l = snap ? 0.3 : 0.1;
	float d = 0.1 - abs(l - length(uv));
	float dd = 0.5 * fwidth(d);
	float a = smoothstep(-dd, dd, d);
	COLOR.a *= a;
}

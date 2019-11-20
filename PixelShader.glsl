#version 130								
uniform vec2 resolution;
uniform float time;

float map(vec3 p) {
	vec3 q = fract(p) * 2.0 - 1.0;
	return length(q) - 0.25;
}

float trace(vec3 original, vec3 ray) {
	float t = 0.0;
	for (int i = 0; i < 64; i++) {
		vec3 p = original + ray * t;
		float d = map(p);
		t += d * 0.5;
	}

	return t;
}

void main()
{
	vec2 uv = resolution.xy / gl_FragCoord.xy;
	uv = uv * 2.0 - 1.0;
	uv.x *= gl_FragCoord.x / gl_FragCoord.y;
	vec3 r = normalize(vec3(uv, 1.0));
	
	float u_time = sin(time) * 0.25;
	r.xz *= mat2(cos(u_time), -sin(u_time), sin(u_time), cos(u_time));

	vec3 o = vec3(0.0, sin(time), sin(time));
	float t = trace(o, r);
	float fog = 1.0 / (1.0 + t * t * 0.1);
	vec3 fc = vec3(fog);


	gl_FragColor = vec4(fc, 1.0);
}
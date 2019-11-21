#version 130
#define PI 3.14159265359
uniform float windowWidth;
uniform float windowHeight;
uniform float time;

// Function that converts HSV colors to RGB
vec3 hsv2rgb (vec3 hsv) {
    return hsv.z * (1.0 + 0.5 * hsv.y * (cos (2.0 * PI * (hsv.x + vec3 (0.0, 0.6667, 0.3333))) - 1.0));
}

// Distance function
float map(vec3 p) {
	vec3 q = fract(p) * 2.0 - 1.0;
	return length(q) - 0.25;
}

// Raymarching function
float trace(vec3 original, vec3 ray) {
	float t = 0.0;
	for (int i = 0; i < 128; i++) {
		vec3 p = original + ray * t;
		float d = map(p);

		// Ray shortening to blur.
		t += d * 0.5;
	}
	return t;
}

void main()
{
	vec2 uv = gl_FragCoord.xy / vec2(windowWidth, windowHeight);
	uv = uv * 2.0 - 1.0;

	// Normalize ray
	vec3 r = normalize(vec3(uv, 1.0));
	
	// Origin
	vec3 o = vec3(0.0, 0.0, -sin(time));

	// Rotate origin and ray
	float a = time * 0.3;
    mat2 rot = mat2(cos(a), -sin(a), sin(a), cos(a));
	o.xz *= rot;
    r.xy *= rot;
    r.xz *= rot;

	// Raymarch
	float t = trace(o, r);

	// Calculate color from the angle
	vec3 p = o + t * r;
    float angle = atan(p.x, p.z) / PI / 2.0;
    vec3 color = hsv2rgb(vec3(angle, 1.0, 1.0));

	/*
	// Color of fogging
	float fog = 1.0 / (1.0 + t * t * 0.1);
	vec3 fc = vec3(fog);
	*/

	gl_FragColor = vec4(color / (1. + t * t * .1), 1.0);
}
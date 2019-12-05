#version 130
#define PI 3.14159265359
uniform float windowWidth;
uniform float windowHeight;
uniform float time;

// Function converts HSV colors to RGB
vec3 hsv2rgb (vec3 hsv) {
	vec3 rgb = clamp(abs(mod(hsv.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
	return hsv.z * mix( vec3(1.0), rgb, hsv.y);
}

// Will create multiple equally spaced spheres.
float map(vec3 p) {
	vec3 q = fract(p) * 2.0 - 1.0;
	return length(q) - 0.5;
}

// Raymarching function
// Receives the original and the ray and casts the ray outwards towards the object in the map() function by multiplying it by t.
float trace(vec3 original, vec3 ray) {
	float t = 0.0;
	for (int i = 0; i < 128; i++) {
		vec3 p = original + ray * t;
		float d = map(p);
		t += d * 0.5;
	}
	return t;
}

void main()
{
	// Pixel coordinates
	vec2 uv = gl_FragCoord.xy / vec2(windowWidth, windowHeight);
	uv = uv * 2.0 - 1.0;

	// Generate a ray with origin and direction 
	vec3 o = vec3(0.0, 0.0, -sin(time)); 
	vec3 r = normalize(vec3(uv, 1.0));

	// Rotate origin and ray
	float a = time * 0.3;
    mat2 rot = mat2(cos(a), -sin(a), sin(a), cos(a));
	o.xz *= rot;
    r.xy *= rot;
    r.xz *= rot;

	// Raymarch
	float t = trace(o, r);

	// Calculate color based on the angle
	vec3 p = o + t * r;
    float angle = atan(p.x, p.z) / PI / 2.0;
    vec3 color = hsv2rgb(vec3(angle, 1.0, 1.0));

	gl_FragColor = vec4(color / (1. + t * t * .1), 1.0);
}
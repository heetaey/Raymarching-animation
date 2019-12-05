/*	
Seattle University, FQ2019
CPSC 5700 - Computer Graphics
Project - ScreenSaver
Jaewon Jeong, Heetae Yang
*/

#version 130
#define PI 3.14159265359
uniform float windowWidth;
uniform float windowHeight;
uniform float time;

/**
 * Function converts HSV colors to RGB
 * Official HSV to RGB conversion: https://en.wikipedia.org/wiki/HSL_and_HSV#HSV_to_RGB
 */
vec3 hsv2rgb (vec3 hsv) {
	vec3 rgb = clamp(abs(mod(hsv.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
	return hsv.z * mix( vec3(1.0), rgb, hsv.y);
}

/**
 * Creates spheres and repeat them; reduced the radius by 0.5
 *
 */
float SDFsphere(vec3 p) {
	vec3 q = fract(p) * 2.0 - 1.0;
	return length(q) - 0.5;
}

/**
 * Raymarching function
 * Receives the original and the ray and casts the ray outwards
 * towards the object in the SDFsphere function by multiplying it by t.
 */
float trace(vec3 original, vec3 ray) {
	float t = 0.0;
	for (int i = 0; i < 64; i++) {
		vec3 p = original + ray * t;
		float d = SDFsphere(p);
		t += d * 0.5;
	}
	return t;
}

void main()
{
	// Pixel coordinates
	vec2 uv = gl_FragCoord.xy / vec2(windowWidth, windowHeight);
	uv = uv * 2.0 - 1.0;

	// Generate a ray with origin and its direction by normalizing
	vec3 o = vec3(0.0, 0.0, -sin(time)); 
	vec3 r = normalize(vec3(uv, 1.0));

	// Rotate origin and ray in 3D; 'a' is changed by the time.
	float a = time * 0.3;
    mat2 rot = mat2(cos(a), -sin(a), sin(a), cos(a));

	// Will rotate the xy, xz values of the origin and normalized points
	// by the defined rot value above.
	o.xz *= rot;
    r.xy *= rot;
    r.xz *= rot;

	// Raymarch: calculate the distance a ray moves into the scene before hitting something.
	float t = trace(o, r);

	// Calculate colors based on the angle
	vec3 p = o + t * r;
    float angle = atan(p.x, p.z) / PI / 2.0;

	// Sets the color
    vec3 color = hsv2rgb(vec3(angle, 1.0, 1.0));

	gl_FragColor = vec4(color / (1. + t * t * .1), 1.0);
}
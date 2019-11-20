#version 130							
in vec2 point;							
uniform mat4 view;
	void main() {								
	gl_Position = vec4(point, 0, 1);		
}
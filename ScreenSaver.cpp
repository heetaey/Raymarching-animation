/*	
Seattle University, FQ2019
CPSC 5700 - Computer Graphics
Project - ScreenSaver
Jaewon Jeong, Heetae Yang
*/

#include <glad.h>
#include <glfw3.h>
#include <stdio.h>
#include <time.h>
#include "GLXtras.h"
#include "Camera.h"

// Window size initialization
int winWidth = 800, winHeight = 800;

// Camera initialization with screen Width, screen Height, rotation, tranlation, and FOV
Camera camera(winWidth / 2, winHeight, vec3(0, 0, 0), vec3(0, 0, -1), 30);

// GPU identifiers
GLuint vBuffer = 0;
GLuint program = 0;
float start = clock();

void InitVertexBuffer() {
	float pts[][2] = { {-1,-1},{-1,1},{1,1},{1,-1} };	// 'object'
	glGenBuffers(1, &vBuffer);							// ID for GPU buffer
	glBindBuffer(GL_ARRAY_BUFFER, vBuffer);				// make it active
	glBufferData(GL_ARRAY_BUFFER, sizeof(pts), pts, GL_STATIC_DRAW);
}

void Display(GLFWwindow* w) {
	glClearColor(1, 1, 1, 1);
	glClear(GL_COLOR_BUFFER_BIT);
	glUseProgram(program);							// ensure correct program
	glBindBuffer(GL_ARRAY_BUFFER, vBuffer);			// activate vertex buffer
	
	// Clocks implemented in order to calculate the movement of object by the time.
	float end = clock();
	float time = (end - start) / CLOCKS_PER_SEC;

	// Set window size
	int screenWidth, screenHeight;
	glfwGetWindowSize(w, &screenWidth, &screenHeight);

	// Set vertex attribute pointers & uniforms
	VertexAttribPointer(program, "point", 2, 0, (void*)0);

	SetUniform(program, "time", time);
	SetUniform(program, "windowWidth", (float)screenWidth);
	SetUniform(program, "windowHeight", (float)screenHeight);
	glDrawArrays(GL_QUADS, 0, 4);	    // display entire window
	glFlush();							// flush GL ops
}

// Resize to dynamically change the viewport whenever user changes window size
void Resize(GLFWwindow* w, int width, int height) {
	camera.Resize(width, height);
	glViewport(0, 0, width, height);
}

void Keyboard(GLFWwindow* window, int key, int scancode, int action, int mods) {
	if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)		// test for program exit
		glfwSetWindowShouldClose(window, GLFW_TRUE);
}

void GlfwError(int id, const char* reason) {
	printf("GFLW error %i: %s\n", id, reason);
	getchar();
}

void APIENTRY GlslError(GLenum source, GLenum type, GLuint id, GLenum severity,
	GLsizei len, const GLchar* msg, const void* data) {
	printf("GLSL Error: %s\n", msg);
	getchar();
}

int AppError(const char* msg) {
	glfwTerminate();
	printf("Error: %s\n", msg);
	getchar();
	return 1;
}

int main() {												// application entry
	glfwSetErrorCallback(GlfwError);						// init GL toolkit
	if (!glfwInit())
		return 1;
	
	// Creates a window with given sizes and name
	GLFWwindow* w = glfwCreateWindow(winWidth, winHeight, "ScreenSaver", NULL, NULL);
	if (!w)
		return AppError("can't open window");

	glfwMakeContextCurrent(w);
	gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);	// set OpenGL extensions
	// following line will not compile unless glad.h >= OpenGLv4.3
	glDebugMessageCallback(GlslError, NULL);

	// Imports shaders from external files
	int v = CompileShaderViaFile("VertexShader.glsl", GL_VERTEX_SHADER);
	int p = CompileShaderViaFile("PixelShader.glsl", GL_FRAGMENT_SHADER);
	program = LinkProgram(v, p);
	
	if (!(program))
		return AppError("can't link shader program");

	InitVertexBuffer();										// set GPU vertex memory
	glfwSetKeyCallback(w, Keyboard);
	glfwSetWindowSizeCallback(w, Resize);					// able to change the window size
	glfwSwapInterval(1);

	while (!glfwWindowShouldClose(w)) {						// event loop
		Display(w);
			if (PrintGLErrors())							// test for runtime GL error
			getchar();										// if so, pause
		glfwSwapBuffers(w);									// double-buffer is default
		glfwPollEvents();
	}
	glfwDestroyWindow(w);
	glfwTerminate();
}
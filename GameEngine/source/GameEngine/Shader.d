///
module GameEngine.Shader;

private
{
    import derelict.opengl3.gl3,
           derelict.glfw3.glfw3;

    import std.string : toStringz;
    import std.exception;
}

/++
+   Contains the code for the exceptions thrown by the 'Shader' class.
++/
class ShaderException : Exception
{
    /++
    +   Calls the Exception constructor.
    +
    +   Params:
    +       Message = The message shown when the exception is thrown.
    ++/
    this(string Message)
    {
        super(Message);
    }
}

/++
+   Which type of shader it is.
++/
enum ShaderTypes
{
    Vertex,
    Fragment
}

/++
+   Creates Shader programs, and uses Shaders.
++/
class Shader
{
    /++
    +   Sets the Window pointer and constructs the Renderer.
    ++/
    this(GLFWwindow* Window)
    {
        this.Wnd = Window;

        this.VertexShader = glCreateShader(GL_VERTEX_SHADER);
        this.FragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    }

    /++
    +   Compiles the shaders.
    +
    +   Params:
    +       VertexCode = The vertex shader code.
    +       FragmentCode = The fragment shader code.
    ++/
    void CompileShaders(string VertexCode, string FragmentCode)
    {
        auto VCode = VertexCode.toStringz;
        auto FCode = FragmentCode.toStringz;

        glShaderSource(this.VertexShader, 1, &VCode, null);
        glShaderSource(this.FragmentShader, 1, &FCode, null);

        glCompileShader(this.VertexShader);
        glCompileShader(this.FragmentShader);

        CheckShaderProgram(this.VertexShader);
        CheckShaderProgram(this.VertexShader);
    }

private:
    GLFWwindow* Wnd;
    GLuint VertexShader, FragmentShader;

    /++
    +   Checks if the shader program is compiled.
    +
    +   Params:
    +       CompiledShader = The shader program, compiled, to be checked.
    ++/
    void CheckShaderProgram(GLuint CompiledShader)
    {
        GLint Compiled;
        glGetShaderiv(CompiledShader, GL_COMPILE_STATUS, &Compiled);     

        if(Compiled)
            return;

        GLint InfoLength = 0;
        glGetShaderiv(CompiledShader, GL_INFO_LOG_LENGTH, &InfoLength);

        auto Buffer = new GLchar[InfoLength];
        glGetShaderInfoLog(CompiledShader, InfoLength, &InfoLength, Buffer.ptr);

        throw new ShaderException("Failed to compile shader. GLSL Error Message is: " ~ Buffer.assumeUnique);
    }    
}
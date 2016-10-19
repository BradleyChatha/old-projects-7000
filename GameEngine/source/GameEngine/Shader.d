///
module GameEngine.Shader;

private
{
    import derelict.opengl3.gl3,
           derelict.glfw3.glfw3;

    import std.string : toStringz;
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

        if(!CheckShaderProgram(this.VertexShader))
            throw new ShaderException("Failed to compile Vertex Shader.");
        if(!CheckShaderProgram(this.VertexShader))
            throw new ShaderException("Failed to compile Fragment Shader.");
    }

private:
    GLFWwindow* Wnd;
    GLuint VertexShader, FragmentShader;

    /++
    +   Checks if the shader program is compiled.
    +
    +   Params:
    +       Program = The shader program, compiled, to be checked.
    +
    +   Returns:
    +       True = Compiled correctly.
    +       False = Didn't compile correctly.
    ++/
    bool CheckShaderProgram(GLuint Program)
    {
        GLint Compiled;
        glGetShaderiv(Program, GL_COMPILE_STATUS, &Compiled);        
        
        if(!Compiled)
            return false;
        return true;
    }    
}
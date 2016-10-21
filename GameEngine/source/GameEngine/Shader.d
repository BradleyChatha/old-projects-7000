///
module GameEngine.Shader;

private
{
    import derelict.opengl3.gl3,
           derelict.glfw3.glfw3;

    import std.string : toStringz;
    import std.exception;
    import std.meta;
    import std.traits;
    import std.stdio;
    import std.file;
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
+   Creates Shader programs, and uses Shaders.
++/
class Shader
{
    /++
    +   Sets the Window pointer and constructs the Renderer.
    ++/
    this()
    {
        this.VertexShader = glCreateShader(GL_VERTEX_SHADER);
        this.FragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        this.Program = glCreateProgram();
    }

    /++
    +   Compiles the shaders from a hard coded string.
    +
    +   Params:
    +       VertexCode = The vertex shader code.
    +       FragmentCode = The fragment shader code.
    +       UseProgram = If true (by default is) then the program is used straight after complation, otherwise Shader.Use() has to be called in order to enable the shader. 
    ++/
    void CompileShadersFromString(string VertexCode, string FragmentCode, bool UseProgram = true)
    {
        auto VCode = VertexCode.toStringz;
        auto FCode = FragmentCode.toStringz;

        glShaderSource(this.VertexShader, 1, &VCode, null);
        glShaderSource(this.FragmentShader, 1, &FCode, null);

        glCompileShader(this.VertexShader);
        glCompileShader(this.FragmentShader);
        this.CheckShaderProgram(this.VertexShader);
        this.CheckShaderProgram(this.VertexShader);

        glAttachShader(this.Program, this.VertexShader);
        glAttachShader(this.Program, this.FragmentShader);
        glLinkProgram(this.Program);
        this.DeleteShaders();     
        this.CheckShaderLink();

        if(UseProgram)
        {
            this.Use();
        }
    }

    /++
    +   Compiles shaders from shader files.
    +   Params:
    +       VertexFile = The vertex shader file.
    +       FragmentFile = The fragment shader file.
    +       UseProgram = If true (by default is) then the program is used straight after complation, otherwise Shader.Use() has to be called in order to enable the shader. 
    ++/
    void CompileShadersFromFile(string VertexFile, string FragmentFile, bool UseProgram = true)
    {
        File ShaderFile = File(VertexFile, "R");

        if(!ShaderFile.isOpen())
            throw new ShaderException("Failed to open shader: " ~ VertexFile);
        ShaderFile.close();
        
        string VertexCode = cast(string)std.file.read(VertexFile);

        ShaderFile.open(FragmentFile, "R");
        if(!ShaderFile.isOpen())
            throw new ShaderException("Failed to open shader: " ~ VertexFile);
        ShaderFile.close();
        
        string FragmentCode = cast(string)std.file.read(VertexFile);

        this.CompileShadersFromString(VertexCode, FragmentCode, UseProgram);
    }

    /++
    +   Sets the value of Uniform floats.
    +
    +   Params:
    +       var = The name of the Uniform variable in the Shader.
    +       floats = The floats to be passed into the shader Uniform variable.
    ++/
    void SetUniformFloat(Floats...)(string var, Floats floats)
    if(allSatisfy!(isFloatingPoint, Floats))
    {
        if(floats.length > 4)
        {
            throw new ShaderException("Length of floats is too large. Max amount is four.");

        }

        GLint Location = glGetUniformLocation(this.Program, var.ptr);
        CheckUniformLocation(Location);      

        static if(floats.length == 1)
        {
            glUniform1f(Location, floats);
        }
        else static if(floats.length == 2)
        {
            glUniform2f(Location, floats);
        }
        else static if(floats.length == 3)
        {
            glUniform3f(Location, floats);
        }
        else static if(floats.length == 4)
        {
            glUniform4f(Location, floats);
        }
    }

    /++
    +   Sets the value of Uniform ints.
    +
    +   Params:
    +       var = The name of the Uniform variable in the Shader.
    +       ints = The ints to be passed into the shader Uniform variable.
    ++/
    void SetUniformInt(Ints...)(string var, Ints ints)
    if(allSatisfy!(isSigned, Ints))
    {
        if(ints.length > 4)
            throw new ShaderException("Length of Ints is too large. Max amount is four.");

        GLint Location = glGetUniformLocation(this.Program, var.ptr);
        CheckUniformLocation(Location);      

        static if(ints.length == 1)
        {
            glUniform1i(Location, ints);
        }
        else static if(ints.length == 2)
        {
            glUniform2i(Location, ints);
        }
        else static if(ints.length == 3)
        {
            glUniform3i(Location, ints);
        }
        else static if(ints.length == 4)
        {
            glUniform4i(Location, ints);
        }
    }

    /++
    +   Sets the value of Uniform unsigned ints.
    +
    +   Params:
    +       var = The name of the Uniform variable in the Shader.
    +       uInts = The unsigned ints to be passed into the shader Uniform variable.
    ++/
    void SetUniformUInt(UInts...)(string var, UInts uInts)
    if(allSatisfy!(isUnsigned, UInts))
    {
        if(UInts.length > 4)
            throw new ShaderException("Length of UInts is too large. Max amount is four.");

        GLint Location = glGetUniformLocation(this.Program, var.ptr);
        CheckUniformLocation(Location);      

        static if(uInts.length == 1)
        {
            glUniform1ui(Location, uInts);
        }
        else static if(uInts.length == 2)
        {
            glUniform2ui(Location, uInts);
        }
        else static if(uInts.length == 3)
        {
            glUniform3ui(Location, uInts);
        }
        else static if(uInts.length == 4)
        {
            glUniform4ui(Location, uInts);
        }
    }

    /++
    +   Use the shader program.
    ++/
    void Use()
    {
        glUseProgram(this.Program);
    }

    /++
    +   Stops the GLSL program and destroys it.
    ++/
    void Discard()
    {
        
    }

private:
    GLuint VertexShader, FragmentShader, Program;

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

        this.DeleteShaders();
        throw new ShaderException("Failed to compile shader. GLSL Error Message is: " ~ Buffer.assumeUnique);
    }

    /++
    +   Checks to make sure that the program has been linked correctly
    ++/
    void CheckShaderLink()
    {
        GLint Linked;
        glGetProgramiv(this.Program, GL_LINK_STATUS, &Linked);

        if(Linked)
            return;

        GLint InfoLength = 0;
        glGetProgramiv(this.Program, GL_INFO_LOG_LENGTH, &InfoLength);

        auto Buffer = new GLchar[InfoLength];
        glGetProgramInfoLog(this.Program, InfoLength, &InfoLength, Buffer.ptr);

        throw new ShaderException("Failed to link shader. GLSL Linker Error Message is: " ~ Buffer.assumeUnique);
    }

    /++
    +   Checks the given Uniform location is correct.
    ++/
    void CheckUniformLocation(GLint Location)
    {
        if(Location == -1)
            throw new ShaderException("Uniform does not exsist.");
    }

    /++
    +   Delete the compiled shaders.
    ++/
    void DeleteShaders()
    {
        this.DetachShaders();
        
        glDeleteShader(this.VertexShader);
        glDeleteShader(this.FragmentShader);
    }

    /++
    +   Detaches the shdaers from the GL Program
    ++/ 
    void DetachShaders()
    {
        glDetachShader(this.Program, this.VertexShader);
        glDetachShader(this.Program, this.FragmentShader);
    }   
}
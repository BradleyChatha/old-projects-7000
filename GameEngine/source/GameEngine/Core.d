///
module GameEngine.Core;

private
{
    import derelict.glfw3.glfw3,
           derelict.opengl3.gl3;
}

/++
+   Contains the code for the exceptions thrown by the 'Core' class.
++/
class CoreException : Exception
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
+   Contains the main variables and is responible for initing systems and uniniting them.
++/
class Core
{
public:
    /++
    +   Loads in the required derelict libraries.
    ++/
    this()
    {
        DerelictGLFW3.load();
        DerelictGL3.load();

        if(!glfwInit())
            throw new CoreException("Failed to initalise GLFW!");
    }

    /++
    +   Unloads all of the libraries when they're not needed anymore.
    ++/
    ~this()
    {
        glfwTerminate();
    }
}
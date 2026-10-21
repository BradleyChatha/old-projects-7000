///
module GameEngine.Window;

private
{
    import derelict.glfw3.glfw3, 
           derelict.opengl3.gl3;

    import std.string : toStringz;
}

/++
+   Contains the code for the exceptions thrown by the 'Window' class.
++/
class WindowException : Exception
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
+   Contains information about colours.
++/
struct Colour
{
    /++
    +   Creates a new colour.
    +   
    +   Params:
    +       r = How much red is in the colour.
    +       g = How much green is in the colour.
    +       b = How much blue is in the colour.
    +       a = The alpha intensity.
    ++/
    this(float r, float g, float b, float a)
    {
        this.R = r;
        this.G = g;
        this.B = b;
        this.A = a;
    }

    float R;
    float G;
    float B;
    float A;
}

/++
+   Holds the information for creating new windows.
++/
class Window
{
    /++
    +   Creates a new window for rendering to.
    +
    +   Params:
    +       Title = The title of the window.
    +       Width = How wide the window is.
    +       Height = How high the window is.
    ++/
    this(string Title, int Width, int Height)
    {
        this.Wnd = glfwCreateWindow(Width, Height, Title.toStringz(), null, null);

        if(!this.Wnd)
        {
            glfwTerminate();
            throw new WindowException("Failed to create a new glfw window");
        }

        glfwMakeContextCurrent(this.Wnd);

        DerelictGL3.reload();

        glfwSwapInterval(0);
    }


    /++
    +   Checks if the current window is open or not.
    +
    +   Returns:
    +       True = Window is open.
    +       False = Window is closed.
    ++/
    bool IsOpen()
    {
        glfwPollEvents();
        return !(glfwWindowShouldClose(this.Wnd));
    }

    /++
    +   Clears the things which were rendered to the screen last frame.
    +
    +   Params:
    +       colour = The colour which the window will be cleared to.
    ++/
    void Clear(Colour colour = Colour(0, 0, 0, 1))
    {
       	glClear(GL_COLOR_BUFFER_BIT);
	    glClearColor(colour.R, colour.G, colour.B, colour.A);
    }

    /++
    +   Renders everything to screen when ready.
    ++/
    void Draw()
    {
        glfwSwapBuffers(this.Wnd);
    }

    /++
    +   Enables or disables VSync.
    +
    +   Params:
    +       Enabled = If this is true then VSync will be enables else it will be disabled.
    ++/
    void EnableVsync(bool Enabled = true)
    {
        if(Enabled)
            glfwSwapInterval(1);
        else
            glfwSwapInterval(0);
    }

    /++
    +   Closes the Window if it is open.
    ++/
    void Close()
    {
        if(this.IsOpen)
            glfwDestroyWindow(this.Wnd);
    }

    /++
    +   Gets a pointer to the GLFWwindow for other systems to use, should they need to.
    +   
    +   Returns:
    +       GLFWwindow*
    ++/
    GLFWwindow* GetWindow()
    {
        return this.Wnd;
    }

private:
    GLFWwindow* Wnd;
}

///
module GameEngine.Renderer2D;

private
{
    import derelict.glfw3.glfw3,
           derelict.opengl3.gl3;
}

/++
+   Renders 2D objects to the screen
++/
class Renderer2D
{
    /++
    +   Sets the Window pointer and constructs Renderer2D.
    ++/
    this(GLFWwindow* Window)
    {
        this.Wnd = Window;
    }

private:
    GLFWwindow* Wnd;
}
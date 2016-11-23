/++
 + Contains code for creating and manipulating a window.
 + ++/
module jengine.graphics.window;

private
{
    import std.experimental.logger;
    import std.exception           : enforce;
    import std.typecons            : BitFlags;
    import jengine.core.maths : Vector2u, Vector2f, Vector2i, asVector2;
    import jengine.graphics.renderer;
    import jengine.core.post;
    import jengine.thirdparty;
}

/++
 + Contains an interface to create and manipulate a window.
 + ++/
final class Window
{
    /++
     + An enumeration of the different ways to style a window.
     + ++/
    enum Style
    {
        /++
         + The window will have a close button.
         + ++/
        Close = 1 << 0
    }

    /++
     + An alias to a `BitFlags` version of `Style`, used for added safety.
     + ++/
    alias StyleFlags = BitFlags!Style;

    /++
     + An alias to the type used as the window handle.
     + ++/
    alias Handle = GLFWwindow*;

    private
    {
        Handle      _handle;
        string      _title;
        bool        _usingVsync;
        //Input       _input;
        //Renderer    _renderer;

        extern(C) static void onGlfwError(int code, const(char)* message) nothrow
        {
            import std.string    : fromStringz;
            import std.exception : assumeWontThrow;
            errorf("[GLFW has reported an error. Code = %s. Message = %s]", code, message.fromStringz).assumeWontThrow;
        }
    }

    public
    {
        /++
         + Creates a new window.
         + 
         + Exceptions:
         +  `WindowException` if the window couldn't be created.
         + 
         + Params:
         +  name        = The name of the window.
         +  size        = The size of the window.
         +  style       = The window's style.
         +  glVersion   = The version of OpenGL to use. X = Major, Y = Minor.
         + ++/
        this(string name, in Vector2u size, in StyleFlags style = Style.Close, in Vector2u glVersion = Vector2u(4, 0))
        {
            import std.string : toStringz;

            // Setup GLFW
            enforce(glfwInit(), new WindowException("Unable to initialise GLFW."));
            glfwSetErrorCallback(&onGlfwError);

            trace("[Creating Window]");
            tracef("[Window Name = %s. Size = %s. Style = %s. GL = %s.]", name, size, style, glVersion);

            // Setup the window
            glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, glVersion.x);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, glVersion.y);
            this._handle = glfwCreateWindow(size.x, size.y, name.toStringz, null, null);
            enforce(this._handle !is null, new WindowException("Failed to create window."));

            // Setup OpenGL
            glfwMakeContextCurrent(this.handle);
            auto vers = DerelictGL3.reload();
            tracef("[OpenGL version that was loaded = %s]", vers);

            // Setup the other sub-systems.
            this.title      = name;
            //this._input     = new Input(this);
            //this._renderer  = new Renderer();
            //this._renderer.onInit(this);
        }

        /++
         + Destroys the window.
         + ++/
        void onUninit()
        {
            trace("[Uninitialisaing Window]");
            if(this._handle !is null)
            {
                trace("[Destroying Window handle]");
                glfwDestroyWindow(this.handle);
                this._handle = null;
            }

            /+
            if(this._input !is null)
            {
                trace("[Destroying Window Input]");
                this._input = null;
            }

            if(this._renderer !is null && this._renderer.hasInit)
            {
                trace("[Destroying Window Renderer]");
                this._renderer.onUninit();
                this._renderer = null;
            }+/
        }

        /++
         + Closes the window.
         + ++/
        @trusted @nogc
        void close() nothrow
        {
            glfwSetWindowShouldClose(this.handle, 1);
        }

        /++
         + Displays any changes made to the window.
         + ++/
        @trusted @nogc
        void display() nothrow
        {
            glfwSwapBuffers(this.handle);
        }

        /++
         + Returns:
         +  The window's size.
         + ++/
        @property @trusted @nogc
        Vector2u size() nothrow 
        {
            Vector2i siz;
            glfwGetWindowSize(this.handle, &siz.vector[0], &siz.vector[1]);
            return siz.asVector2!uint;
        }

        /++
         + Sets the window's size.
         + 
         + Params:
         +  size_ = The size to set to the window to.
         + ++/
        @property @trusted @nogc
        void size(in Vector2u size_) nothrow
        {
            glfwSetWindowSize(this.handle, size_.x, size_.y);
        }

        /++
         + Returns:
         +  The window's title.
         + ++/
        @property @safe @nogc
        string title() nothrow const
        {
            return this._title;
        }

        /++
         + Sets the window's title.
         + 
         + Params:
         +  title_ = The title to give the window.
         + ++/
        @property @trusted
        void title(string title_) nothrow
        {
            import std.string    : toStringz;
            import std.exception : assumeWontThrow;

            assumeWontThrow(tracef("[Setting Window title to '%s']", title_));
            glfwSetWindowTitle(this.handle, title_.toStringz);
            this._title = title_;
        }

        /++
         + Returns:
         +  Whether the window is using VSync or not.
         + ++/
        @property @safe @nogc
        bool vsync() nothrow const
        {
            return this._usingVsync;
        }

        /++
         + Sets whether the window is using vsync or not.
         + 
         + Params:
         +  vsync_ = Should the window use Vsync?
         + ++/
        @property @trusted @nogc
        void vsync(bool vsync_) nothrow
        {
            this._usingVsync = vsync_;
            if(vsync_)
                glfwSwapInterval(1);
        }

        /++
         + Returns:
         +  `true` if the window is open. `false` otherwise.
         + ++/
        @property @trusted @nogc
        bool isOpen() nothrow
        {
            return !glfwWindowShouldClose(this.handle);
        }

        /++
         + Returns:
         +  An instance of `Input` that is used to respond to any events the window recieves.
         + ++/
        version(none)
        @property @trusted @nogc
        inout(Input) input() nothrow inout
        out(output)
        {
            assert(output !is null);
        }
        body
        {
            return this._input;
        }

        /++
         + Returns:
         +  The window's `Renderer`.
         + ++/
        version(none)
        @property @safe @nogc
        inout(Renderer) renderer() nothrow pure inout
        out(output)
        {
            assert(output !is null, "The renderer is null.");
        }
        body
        {
            return this._renderer;
        }

        /++
         + Notes:
         +  This function should *only* be used in very specific cases, such as for the renderer.
         +  In every other case, a function should be added to the window (or even a new class entirely) to provide
         +  a high-level interface.
         + 
         + Returns:
         +  The handle used by the window.
         + ++/
        @property @safe @nogc
        inout(Handle) handle() nothrow inout
        out(output)
        {
            assert(output !is null);
        }
        body
        {
            return this._handle;
        }
    }
}

/++
 + This class handles managing the input of a `Window`.
 + 
 + Description:  
 +  The Input class has an `alias this` to it's `PostOffice`, for ease of use 
 +  (e.g, instead of `input.events.subscribe` you'd be able to use `input.subscribe`).
 + 
 +  A `Mouse` struct is provided via `Input.mouse`, which will keep the state of the mouse up to date.
 + 
 +  Basic usage includes using `input.subscribe(Input.Events.SomeEvent, &myHandler)` to subscribe to a specific window event.
 + ++/
version(none)
final class Input : IPostBox
{
    import jengine.core.post;

    mixin(IPostBox.generateOnMail!Input);

    alias events this;

    /++
     + Contains the state of the mouse.
     + ++/
    struct Mouse
    {
        /// The position of the mouse, relative to the top left corner of the screen.
        Vector2f position;

        /// `true` if the left mouse button is down. `false` otherwise.
        bool     leftButtonDown;

        /// `true` if the right mouse button is down. `false` otherwise.
        bool     rightButtonDown;

        /// `true` if the middle mouse button is down. `false` otherwise.
        bool     middleButtonDown;
    }

    private
    {
        PostOffice  _office;
        Window      _window;
        Mouse       _mouse;

        this(Window window)
        {
            assert(window !is null, "The window is null.");
            trace("[Creating Window Input]");

            this._window = window;
            this._office = new PostOffice();
            
            this.subscribe(this);
        }
    }

    public
    {
        /++
         + Processes all pending window events.
         + 
         + Description:
         +  Every window event will be mailed to the `Input.events` office, where the mail's type is the event's type,
         +  and the mail itself is an `Input.MailT`. For example, when the mouse is moved, a `MailT` with the type
         +  `sfEvtMouseMoved` is mailed.
         + ++/
        void processEvents()
        {
            sfEvent e;
            while(sfRenderWindow_pollEvent(this._window.handle, &e))
            {
                // Temporary measure. In the future I want to reuse a single/pool of message objects
                // instead of constantly allocating them.
                this.events.mailValue!sfEvent(cast(Mail.MailTypeT)e.type, e);
            }
        }

        /++
         + Description:
         +  Whenever the window this class is attached to recieves an event, then an `Input.MailT` mail is posted,
         +  where the mail's type is the same as the event's type.
         + 
         +  e.g. To listen for if the close button is pressed, a call such as 
         +  `window.input.events.subscribe(sfClose, &onClose)` should be made.
         + 
         + Returns:
         +  A `PostOffice` that can be used to listen for mail triggered by a window event.
         + ++/
        @property @safe @nogc
        inout(PostOffice) events() nothrow inout
        out(output)
        {
            assert(output !is null, "The PostOffice is null, for some reason.");
        }
        body
        {
            return this._office;
        }

        /++
         + Returns:
         +  The state of the `Mouse`.
         + ++/
        @property @safe @nogc
        Mouse mouse() nothrow pure const
        {
            return this._mouse;
        }
    }
}

/++
 + Thrown whenever an issue arrises when using a `Window`.
 + ++/
class WindowException : Exception
{
    /**
     * Creates a new instance of Exception. The next parameter is used
     * internally and should always be $(D null) when passed by user code.
     * This constructor does not automatically throw the newly-created
     * Exception; the $(D throw) statement should be used for that purpose.
     */
    @nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}
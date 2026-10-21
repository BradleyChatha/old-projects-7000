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
     + An alias to the type used as the window handle.
     + ++/
    alias Handle = SDL_Window*;

    private
    {
        Handle         _handle;
        string         _title;
        bool           _usingVsync;
        bool           _close;
        Input          _input;
        Renderer       _renderer;
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
         + ++/
        this(string name, in Vector2u size)
        {
            import std.string : toStringz;
            trace("[Creating Window]");
            tracef("[Window Name = %s. Size = %s.]", name, size);

            // Setup the window
            this._handle = SDL_CreateWindow(name.toStringz,
                                            SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                            size.x,                 size.y,
                                            0);
            enforce(this._handle !is null, new WindowException("Failed to create window. Reason = %s", getSDLError()));

            // Setup the other sub-systems.
            this.title      = name;
            this._input     = new Input(this);
            this._renderer  = new Renderer();
            this._renderer.onInit(this);

            this._input.subscribe(SDL_QUIT, (a, b) { this._close = true; }); // No need to unsubscribe, since the office will be dispose of by then.
        }

        /++
         + Destroys the window.
         + ++/
        void onUninit()
        {
            trace("[Uninitialisaing Window]");

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
            }

            if(this._handle !is null)
            {
                trace("[Destroying Window handle]");
                SDL_DestroyWindow(this.handle);
                this._handle = null;
            }
        }

        /++
         + Returns:
         +  The window's size.
         + ++/
        @property @trusted @nogc
        Vector2u size() nothrow 
        {
            Vector2i siz;
            SDL_GetWindowSize(this.handle, &siz.vector[0], &siz.vector[1]);
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
            SDL_SetWindowSize(this.handle, size_.x, size_.y);
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
            SDL_SetWindowTitle(this.handle, title_.toStringz);
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
         + Notes:
         +  This will reset the `Renderer`'s back buffer to the window's size.
         + 
         + Params:
         +  vsync_ = Should the window use Vsync?
         + ++/
        @property @trusted @nogc
        void vsync(bool vsync_) nothrow
        {
            Renderer.ResetFlags flags = this._renderer.resetFlags;
            this._usingVsync          = vsync_;
            if(vsync_)
                flags |= Renderer.ResetFlags.VSync;
            else
                flags &= ~Renderer.ResetFlags.VSync;

            this._renderer.reset(this.size, flags);
        }

        /++
         + Returns:
         +  `true` if the window has been told to close. `false` otherwise.
         + ++/
        @property @trusted @nogc
        bool shouldClose() nothrow
        {
            return this._close;
        }

        /++
         + Returns:
         +  An instance of `Input` that is used to respond to any events the window recieves.
         + ++/
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
final class Input : IPostBox
{
    mixin(IPostBox.generateOnMail!Input);

    /++
     + The `Mail` posted whenever there is some kind of input event.
     + ++/
    alias EventMail = ValueMail!SDL_Event;
    alias events this;

    /++
     + Contains many other types that are related to the mouse in some way.
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

        @MailBox(SDL_MOUSEMOTION)
        void onMouseMove(PostOffice, EventMail pos)
        {
            this._mouse.position = Vector2f(pos.value.motion.x, pos.value.motion.y);
        }

        @MailBox(SDL_MOUSEBUTTONDOWN)
        void onMouseButtonDown(PostOffice, EventMail mail)
        {
            switch(mail.value.button.button)
            {
                case SDL_BUTTON_LEFT:   this._mouse.leftButtonDown   = true; break;
                case SDL_BUTTON_RIGHT:  this._mouse.rightButtonDown  = true; break;
                case SDL_BUTTON_MIDDLE: this._mouse.middleButtonDown = true; break;

                default: break;
            }
        }

        @MailBox(SDL_MOUSEBUTTONUP)
        void onMouseButtonUp(PostOffice, EventMail mail)
        {
            switch(mail.value.button.button)
            {
                case SDL_BUTTON_LEFT:   this._mouse.leftButtonDown   = false; break;
                case SDL_BUTTON_RIGHT:  this._mouse.rightButtonDown  = false; break;
                case SDL_BUTTON_MIDDLE: this._mouse.middleButtonDown = false; break;

                default: break;
            }
        }
    }

    public
    {
        /++
         + Processes all pending window events.
         +
         + Description:
         +  For every event that is processed, an `Input.EventMail` is mailed, where the type
         +  is event type, e.g. SDL_MOUSEMOTION, SDL_QUIT, etc.
         + ++/
        void processEvents()
        {
            SDL_Event e;
            while(SDL_PollEvent(&e))
            {
                this.mailValue(cast(Mail.MailTypeT)e.type, e);
            }
        }

        /++
         + Description:
         +  This `PostOffice` is used
         + 
         +  e.g. To listen for if the mouse is moved, a call such as 
         +  `window.input.events.subscribe(SDL_MOUSEMOTION, &onMove)` should be made.
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
         +  The current state of the `Mouse`.
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
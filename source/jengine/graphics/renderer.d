/++
 + Contains code for rendering basic stuff to the screen.
 + ++/
module jengine.graphics.renderer;

private
{
    import std.experimental.allocator.mallocator, std.experimental.logger, std.experimental.allocator;
    import std.exception : enforce;

    import jengine.core.engine;
    import jengine.core.maths;
    import jengine.core.cache;
    import jengine.graphics.window;
    import jengine.thirdparty;

    import jaster.smartptr;
    import gl3n.linalg : Vector;
}

/// Note that because gl3n's `Vector` is buggy (or rather, D is) it will store a `uint` instead of a `ubyte`
/// The `checkColour` function is provided to make sure all of the values are within 0-255, and fails an assert otherwise.
alias Colour = Vector!(uint, 4);

/++
 + Checks a `Colour` to make sure it's values are between 0-255.
 +
 + Notes:
 +  This function makes use of `assert`s, so there is no overhead for using it in release builds.
 + 
 + Assertions:
 +  The `r`, `g`, `b`, and `a` values of `colour` must be between 0-255 (inclusive)
 +
 + Params:
 +  colour = The colour to check.
 + ++/
@safe @nogc
void checkColour(const Colour colour) nothrow pure
{
    assert(colour.r >= 0 && colour.r <= 255, "The Red value is out of bounds.");
    assert(colour.g >= 0 && colour.g <= 255, "The Blue value is out of bounds.");
    assert(colour.b >= 0 && colour.b <= 255, "The Green value is out of bounds.");
    assert(colour.a >= 0 && colour.a <= 255, "The Alpha value is out of bounds.");
}

/++
 + 
 + ++/
final class Renderer : IInitialisable!Window
{
    /++
     + Flags used in `Renderer.reset`.
     + ++/
    enum ResetFlags
    {
        /// No flags
        None,

        /// Enable MSAA x2
        MSAAx2,

        /// Enable MSAA x4
        MSAAx4,

        /// Enable MSAA x8
        MSAAx8,

        /// Enable MSAA x16
        MSAAx16,

        /// Enable VSync
        VSync
    }

    /++
     + Flags passed to `Renderer.debugFlags` to control debugging features.
     + ++/
    enum DebugFlags
    {
        /// Use no debugging features.
        None        = BGFX_DEBUG_NONE,

        /// No rendering calls will be submitted to the GPU, making it easier to detect whether
        /// there is a CPU or GPU bottleneck.
        skipDrawing = BGFX_DEBUG_IFH,

        /// Enables wireframe
        wireframe   = BGFX_DEBUG_WIREFRAME,

        /// Displays internal statistics (From BGFX)
        statistics  = BGFX_DEBUG_STATS,

        /// Displays any debug text submitted via `Renderer.renderDebugText`
        text        = BGFX_DEBUG_TEXT
    }

    private
    {
        ResetFlags  _resetFlags;
        DebugFlags  _debugFlags;
        Window      _window;
    }

    public
    {
        /++
        + Called when the class should initialise everything.
        + 
        + Assertions:
        +   `window` must not be `null`.
        + 
        + Params:
        +   window = The `Window` being rendered to.
        + ++/
        void onInit(Window window)
        {
            assert(window !is null, "Attempted to intialise a Renderer using a null Window.");

            // Setup BGFX(This looks so ugly ~_~)
            trace("[Initialising BGFX and Renderer]");
            SDL_SysWMinfo info;
            SDL_VERSION(&info.version_);
            enforce(SDL_GetWindowWMInfo(window.handle, &info), new WindowException("SDL_GetWindowWMInfo failed. Reason = %s", getSDLError()));
            
            bgfx_platform_data_t data;
            version(Windows)
            {
                data.ndt = null;
                data.nwh = info.info.win.window;
            }
            else static assert(false, "Your platform is not supported. It should be easy enough to add support for this part, so please open an issue.");
            bgfx_set_platform_data(&data);
            this.reset(window.size, ResetFlags.None);
            
            enforce(bgfx_init(BGFX_RENDERER_TYPE_OPENGL, BGFX_PCI_ID_NONE),
                new Exception("Unable to initialise BGFX"));

            this._window = window;
        }
        
        /++
        + Called when the class should uninitialise everything.
        + ++/
        void onUninit()
        {
            trace("[Uninitialising Renderer]");
            this._window = null;
            bgfx_shutdown();
        }

        /++
         + Resets the renderer's graphics settings, and changes the back buffer's size.
         + 
         + Params:
         +  bufferSize = The size to make the back buffer, this should generally be the window's size.
         +  flags      = The new graphics settings to use.
         + ++/
        @trusted @nogc
        void reset(Vector2u bufferSize, ResetFlags flags = ResetFlags.None) nothrow
        {
            bgfx_reset(bufferSize.x, bufferSize.y, flags);
        }

        /++
         + Returns:
         +  The last `ResetFlags` given to `Renderer.reset`.
         + ++/
        @property @safe @nogc
        ResetFlags resetFlags() nothrow const
        {
            return this._resetFlags;
        }

        /++
         + Sets what debugging features to use.
         + 
         + Params:
         +  flags = The `DebugFlags` to set.
         + ++/
        @property @trusted @nogc
        void debugFlags(DebugFlags flags) nothrow
        {
            this._debugFlags = flags;
            bgfx_set_debug(cast(uint)flags);
        }

        /++
         + Returns:
         +  A `DebugFlags` containing all the debugging features that are enabled.
         + ++/
        @property @safe @nogc
        DebugFlags debugFlags() nothrow const
        {
            return this._debugFlags;
        }

        /++
        + Returns:
        +  Whether the class has initialised or not.
        + ++/
        @property @safe @nogc
        bool hasInit() nothrow const
        {
            return (this._window !is null);
        }
    }
}
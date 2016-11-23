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
        MSAAx2  = BGFX_RESET_MSAA_X2,

        /// Enable MSAA x4
        MSAAx4  = BGFX_RESET_MSAA_X4,

        /// Enable MSAA x8
        MSAAx8  = BGFX_RESET_MSAA_X8,

        /// Enable MSAA x16
        MSAAx16 = BGFX_RESET_MSAA_X16,

        /// Enable VSync
        VSync   = BGFX_RESET_VSYNC
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
        SkipDrawing = BGFX_DEBUG_IFH,

        /// Enables wireframe
        Wireframe   = BGFX_DEBUG_WIREFRAME,

        /// Displays internal statistics (From BGFX)
        Statistics  = BGFX_DEBUG_STATS,

        /// Displays any debug text submitted via `Renderer.renderDebugText`
        Text        = BGFX_DEBUG_TEXT
    }

    /++
     + Used in `Renderer.renderDebugText`.
     + ++/
    enum DebugColour : ubyte
    {
        ///
        Black   = 0x0,

        ///
        Red     = 0x1,

        ///
        Green   = 0x2,

        ///
        Orange  = 0x3,

        ///
        Blue    = 0x4,

        ///
        Purple  = 0x5,

        ///
        Cyan    = 0x6,

        ///
        White   = 0x7,

        ///
        Gray    = 0x8,

        // Can only have up to 0xF, because of how bgfx_dbg_text works
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

            enforce(bgfx_init(BGFX_RENDERER_TYPE_OPENGL, BGFX_PCI_ID_NONE),
                new Exception("Unable to initialise BGFX"));
            this.reset(window.size, ResetFlags.None);

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
         + Instructs the rendering thread to render all previously submitted render requests.
         + ++/
        @nogc
        void renderFrame() nothrow
        {
            bgfx_frame();
        }

        /++
         + Renders debug text to the screen if `DebugFlags.text` is set.
         + 
         + Params:
         +  position = The position on screen to render the text.
         +             Note that this the position is not in pixels but rather in rows.
         +  colour   = The `DebugColour` to render the text with.
         +  format   = Standard std.format formatting string.
         +  args     = Standard std.format formatting args.
         + ++/
        void renderDebugText(Args...)(const Vector2u position, const DebugColour colour, const(char)[] format, Args args)
        {
            import std.format        : sformat;
            import jaster.containers : DynamicArray;
            DynamicArray!char buffer;
            buffer.length = 512;
            buffer.range.sformat(format, args);
            buffer ~= '\0';

            auto vect = position.asVector2!ushort;
            bgfx_dbg_text_printf(vect.x, vect.y, 
                                 cast(ubyte)((cast(ubyte)DebugColour.Gray << 4) | colour), 
                                 buffer.range.ptr);
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
            this._resetFlags = flags;
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
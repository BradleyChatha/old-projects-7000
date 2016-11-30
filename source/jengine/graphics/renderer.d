/++
 + Contains code for rendering basic stuff to the screen.
 + ++/
module jengine.graphics.renderer;

private
{
    import std.experimental.allocator.mallocator, std.experimental.logger, std.experimental.allocator;
    import std.exception;

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
 + Encodes a `Colour` into a uint representation.
 + 
 + Assertions:
 +  `col` must pass `checkColour`.
 + 
 + Params:
 +  col = The `Colour` to encode.
 + 
 + Returns:
 +  A uint in the form of `0xRRGGBBAA`
 + ++/
@safe @nogc
uint toRGBA8(const Colour col) nothrow pure
{
    col.checkColour();
    return (col.r << 24 |
            col.g << 16 |
            col.b << 8  |
            col.a);
}
///
unittest
{
    static assert(Colour(0xAB, 0xCD, 0xEF, 0xFF).toRGBA8 == 0xABCDEFFF);
}

/++
 + Converts an encoded rgba number into a `Colour`.
 + 
 + Params:
 +  rgba = The number to convert.
 + 
 + Returns:
 +  `rgba` decoded into a `Colour`.
 + ++/
@safe @nogc
Colour fromRGBA8(uint rgba) nothrow pure
out(col)
{
    col.checkColour();
}
body
{
    return Colour((rgba & 0xFF000000) >> 24,
                  (rgba & 0x00FF0000) >> 16,
                  (rgba & 0x0000FF00) >> 8,
                  rgba & 0xFF);
}
///
unittest
{
    static assert((0xABCDEFFF).fromRGBA8 == Colour(0xAB, 0xCD, 0xEF, 0xFF));
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

            Vertex.createDeclaration();
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

/++
 + Describes a vertex.
 + ++/
struct Vertex
{
    private static
    {
        bgfx_vertex_decl_t _decl;
        void createDeclaration()
        {
            bgfx_vertex_decl_begin(&Vertex._decl);
            scope(exit) bgfx_vertex_decl_end(&Vertex._decl);

            bgfx_vertex_decl_add(&Vertex._decl, BGFX_ATTRIB_POSITION, 2, BGFX_ATTRIB_TYPE_FLOAT); // a_position
            bgfx_vertex_decl_add(&Vertex._decl, BGFX_ATTRIB_COLOR0,   4, BGFX_ATTRIB_TYPE_UINT8); // a_color
        }
    }

    /// The vertex's position.
    Vector2f          position;

    /// The vertex's colour.
    /// This type isn't `Colour` since it's a Vector!(uint, 4) (Setting Colour to use ubyte makes it unpractical to use)
    Vector!(ubyte, 4) rgba;

    ///
    this(Vector2f pos, Colour col = Colour(0, 0, 0, 255))
    {
        this.position = pos;
        this.colour   = col;
    }

    /++
     + Sets the vertex's colour from a `Colour`.
     + 
     + Params:
     +  col = The colour to give the vertex.
     + ++/
    @property @safe @nogc
    void colour(const Colour col) nothrow pure
    {
        this.rgba = typeof(rgba)(cast(ubyte)col.r, 
                                 cast(ubyte)col.g, 
                                 cast(ubyte)col.b, 
                                 cast(ubyte)col.a);
    }

    /++
     + Returns:
     +  `Vertex.rgba` as a `Colour`.
     + ++/
    @property @safe @nogc
    Colour colour() nothrow const
    {
        return Colour(this.rgba.r, this.rgba.g, this.rgba.b, this.rgba.a);
    }
}

/++
 + Contains a shader program.
 + ++/
final class Shader
{
    /// An alias to the type used as the Shader's handle.
    alias Handle = bgfx_program_handle_t;

    private
    {
        Handle _handle = Handle(ushort.max);
    }

    public
    {
        ~this()
        {
            if(this._handle.idx != ushort.max)
                bgfx_destroy_program(this.handle);
        }

        /++
         + Creates a new `Shader` using the given shader binaries from memory.
         + 
         + Notes:
         +  Shader files must first be compiled using the `shaderc` tool, and then passed into this function.
         + 
         +  `theAllocator` is used to allocate the returned object, so it is advised to use `Shader.dispose` to dispose
         +  of the shader properly.
         + 
         + Exceptions:
         +  `GraphicsException` if either one of the shaders coulod not be created, or if the program could not be created.
         + 
         + Params:
         +  vertex      = The binary for the vertex shader.
         +  fragment    = The binary for the fragment shader.
         + 
         + Returns:
         +  A newly made `Shader`.
         + ++/
        static Shader fromMemory(const(ubyte)[] vertex, const(ubyte)[] fragment)
        {
            auto shader = theAllocator.make!Shader;
            scope(failure) theAllocator.dispose(shader);

            auto vert = bgfx_create_shader(bgfx_copy(vertex.ptr, vertex.length));
            //auto frag = bgfx_create_shader(bgfx_copy(vertex.ptr, vertex.length));
            //scope(exit)
            //{
            //    if(vert.idx != ushort.max) bgfx_destroy_shader(vert);
            //    if(frag.idx != ushort.max) bgfx_destroy_shader(frag);
            //}
            //enforce(vert.idx != ushort.max, new GraphicsException("The vertex shader could not be created."));
            //enforce(frag.idx != ushort.max, new GraphicsException("The fragment shader could not be created."));

            //shader._handle = bgfx_create_program(vert, frag);
            //enforce(shader._handle.idx != ushort.max, new GraphicsException("The shader program could not be created."));

            return shader;
        }

        /++
         + Disposes of the given `Shader`.
         + 
         + Notes:
         +  Only use this function for `Shader`s allocated with `theShader`.
         + 
         + Params:
         +  shader = The `Shader` to dispose of.
         +           If it is `null`, this function does nothing.
         +           The shader is set to `null` afterwards.
         + ++/
        static void dispose(ref Shader shader)
        {
            if(shader !is null)
            {
                theAllocator.dispose(shader);
                shader = null;
            }
        }

        /++
         + Returns:
         +  The `Handle` being used by this `Shader`.
         + ++/
        @property @safe @nogc
        Handle handle() nothrow const
        out(hand)
        {
            assert(hand.idx != ushort.max, "Attempted to use a null shader handle.");
        }
        body
        {
            return this._handle;
        }
    }
}

/++
 + Thrown whenever something with a graphical class goes wrong.
 + ++/
class GraphicsException : Exception
{
    mixin basicExceptionCtors;
}
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

private enum _debugFontBytes = cast(immutable(ubyte)[])import("debug_font/font.ttf");

version(none):

/++
 + Contains code that knows how to render things.
 + ++/
final class Renderer : IInitialisable!Window
{
    /// The type returned by `Renderer.view`
    alias ViewPointer = AutoSharedPointer!(View, Mallocator, No.useGC);
    private
    {
        Window _window;
        View   _view;
    }

    public
    {
        /++
         + Called when the class should initialise everything.
         + 
         + Assertions:
         +  `hasInit` should return `false`.
         + 
         + Params:
         +  window = The `Window` to render to.
         + ++/
        void onInit(Window window)
        {
            trace("[Initialising renderer]");
            assert(window !is null);
            this._window = window;
            this.view    = View.create(); // Make _view non-null
            this.view    = null;          // Then replace it with the default view
        }
        
        /++
         + Called when the class should uninitialise everything.
         + 
         + Notes:
         +  If a class should keep a reference to the `Engine` passed by `onInit` if it will require it for cleanup.
         + ++/
        void onUninit()
        {
            trace("[Uninitialising renderer]");
            this._window = null;
            View.dispose(this._view);
        }

        /++
         + Clears the screen to a certain colour.
         + 
         + Params:
         +  colour = The colour to clear to.
         + ++/
        void clear(const Colour colour)
        {
            sfRenderWindow_clear(this.window.handle, colour.asNativeColour);
        }

        /++
         + Renders a sprite to the screen.
         + 
         + Assertions:
         +  `sprite` must not be `null`.
         + 
         + Params:
         +  sprite = A reference to the `Sprite` to render.
         + ++/
        void render(const Sprite sprite)
        {
            assert(sprite !is null, "Attempted to render a null sprite");

            if(sprite.visible)
                sfRenderWindow_drawSprite(this.window.handle, sprite.handle, null);
        }

        /++
         + Renders a `Text` to the screen.
         + 
         + Assertions:
         +  `text` must not be `null`.
         + 
         + Params:
         +  text = The `Text` to render.
         + ++/
        void render(const Text text)
        {
            assert(text !is null, "Attempted to render a null Text");
            sfRenderWindow_drawText(this.window.handle, text.handle, null);
        }

        /++
         + Renders a rectangle.
         +
         + Assertions:
         +  `rect` must not be `null`.
         +
         + Params:
         +  rect = The `RectangleShape` to render.
         + ++/
        void render(const RectangleShape rect)
        {
            assert(rect !is null, "Attempted to render a null RectangleShape");
            sfRenderWindow_drawRectangleShape(this.window.handle, rect.handle, null);
        }

        /++
         + Converts a screen position to a world position.
         + 
         + Description:
         +  Imagine that we have the world position (0,0), and that the renderer's main `View` has been moved
         +  50 pixels to the right. Then, imagine we pass (0,0) to this function, it would return (-50,0) as that's
         +  where the position (0,0) would be relative to the camera.
         + 
         + Params:
         +  screenPos = The screen position to convert.
         + 
         + Returns:
         +  `screenPos` as a world position.
         + ++/
        @trusted @nogc
        Vector2f screenToWorldPos(in Vector2f screenPos) nothrow const
        {
            auto vect = sfRenderWindow_mapPixelToCoords(this.window.handle, 
                                                        screenPos.asNativeVector2!int, 
                                                        this._view.handle);
            return Vector2f(vect.x, vect.y);
        }

        /++
         + Converts a world position to a screen position.
         + 
         + Params:
         +  worldPos = The world position to convert.
         + 
         + Returns:
         +  `worldPos` as a screen position.
         + ++/
        @trusted @nogc
        Vector2f worldToScreenPos(in Vector2f worldPos) nothrow const
        {
            auto vect = sfRenderWindow_mapCoordsToPixel(this.window.handle, 
                                                        worldPos.asNativeVector2!float, 
                                                        this._view.handle);
            return Vector2f(vect.x, vect.y);
        }

        /++
         + Notes:
         +  Because the current `View` might be changed, and therefor deallocated while the old one is still being used,
         +  a $(B copy) of the current view is made, and returned as a `ViewPointer`, which will automatically
         +  deallocate the View once all `ViewPointers` to it are destroyed.
         + 
         + Returns:
         +  The current `View` being used.
         + ++/
        @property @trusted
        ViewPointer view()
        {
            return ViewPointer(ViewPointer.SharedPointerT(this._view.copy));
        }

        /++
         + Sets the current `View` of the renderer.
         + 
         + Notes:
         +  A copy of the view is made, so any edits to `view_` after this function will not become visible.
         + 
         + Params:
         +  view_ = The `View` to use.
         +          If `null`, then the default view will be used.
         + ++/
        @property @trusted
        void view(View view_)
        {
            if(view_ is null)
                this._view._handle = sfRenderWindow_getDefaultView(this.window.handle).sfView_copy();
            else
            {
                View.dispose(this._view);
                this._view = view_.copy;
            }

            sfRenderWindow_setView(this.window.handle, this._view.handle);
        }

        /++
         + Returns:
         +  The `Window` being used by the renderer.
         + ++/
        @property @safe @nogc
        inout(Window) window() nothrow pure inout
        out(output)
        {
            assert(output !is null, "The window is null.");
        }
        body
        {
            return this._window;
        }

        /++
         + Returns:
         +  Whether the class has initialised or not.
         + ++/
        @property @safe @nogc
        bool hasInit() nothrow pure const
        {
            return (this._window !is null);
        }
    }
}

/++
 + Contains a shader, which is a small program on the GPU that makes things super pretty.
 + Please see http://www.sfml-dev.org/tutorials/2.4/graphics-shader.php for SFML-specific info
 + about shaders.
 ++/
final class Shader : ICacheable
{
    /++
     + An alias to the type used as the shader's handle.
     ++/
    alias Handle = sfShader*;

    private
    {
        Handle _handle;
    }

    public
    {
        ~this()
        {
            if(this._handle !is null)
                sfShader_destroy(this.handle);
        }

        /++
         + Creates a shader from two shader files.
         +
         + Exceptions:
         +  $(P `Exception` if either parameter is `null`.)
         +  $(P `FileException` if either parameter points to a non-existant file.)
         +  $(P `GraphicsException` if either parameter is not valid GLSL code.)
         +
         + Notes:
         +  The `Shader` is allocated with `theAllocator`.
         +
         + Params:
         +  vertex   = The file containing the vertex shader.
         +  fragment = The file containing the fragment shader.
         +
         + Returns:
         +  A newly made `Shader`.
         ++/
        @trusted
        static Shader fromFile(in char[] vertex, in char[] fragment)
        out(output)
        {
            assert(output !is null, "No shader was made.");
        }
        body
        {
            import std.path    : buildNormalizedPath;
            import std.string  : toStringz;
            import std.file    : FileException, exists, isDir;

            enforce(vertex   !is null, "The path to the vertex shader is null.");
            enforce(fragment !is null, "The path to the fragment shader is null.");

            auto vert = buildNormalizedPath(vertex);
            auto frag = buildNormalizedPath(fragment);

            enforce(vert.exists && !vert.isDir, new FileException(vertex,   "Path for Vertex Shader does not exist, or points to a directory."));
            enforce(frag.exists && !frag.isDir, new FileException(fragment, "Path for Fragment Shader does not exist, or points to a directory."));

            tracef("[Loading Shader from files. Frag = %s. Vert = %s]", frag, vert);
            auto shader    = theAllocator.make!Shader;
            shader._handle = sfShader_createFromFile(vert.toStringz, frag.toStringz);
            scope(failure) theAllocator.dispose(shader);
            tracef("[Shader handle: %s]", shader.handle);

            enforce(shader._handle !is null, new GraphicsException("Unable to create Shader"));

            return shader;
        }

        /++
         + Creates a shader from two GLSL sources.
         + 
         + Exceptions:
         +  $(P `Exception` if either parameter is `null`.)
         +  $(P `GraphicsException` if either parameter is not valid GLSL code.)
         + 
         + Notes:
         +  The `Shader` is allocated with `theAllocator`.
         +
         + Params:
         +  vertex   = The code for the vertex shader.
         +  fragment = The code for the fragment shader.
         + 
         + Returns:
         +  The newly made `Shader`.
         + ++/
        @trusted
        static Shader fromMemory(in char[] vertex, in char[] fragment)
        out(output)
        {
            assert(output !is null, "No shader was made.");
        }
        body
        {
            import std.string : toStringz;

            enforce(vertex   !is null, "The code for the vertex shader is null.");
            enforce(fragment !is null, "The code for the fragment shader is null.");

            trace("[Creating Shader from memory]");
            auto shader    = theAllocator.make!Shader;
            shader._handle = sfShader_createFromMemory(vertex.toStringz, fragment.toStringz);
            scope(failure) theAllocator.dispose(shader); // In case the enforce below throws.

            // I wish there was a way to capture the error message e_e
            enforce(shader._handle !is null, new GraphicsException("The shader could not be compiled."));
            tracef("[Shader handle: %s]", shader.handle);

            return shader;
        }

        /++
         + Disposes of a `Shader` created by `fromMemory` or `fromFile`.
         + 
         + Notes:
         +  The `shader` $(B must have been created by one of the mentioned functions).
         + 
         + Params:
         +  shader = The shader to dispose of.
         +           The referenced passed through is then set to `null`.
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
         + Sets which `Shader` to use when rendering.
         + 
         + Params:
         +  shader = The shader to use when rendering.
         +           Pass `null` to use the default SFML ones again.
         + ++/
        @trusted
        static void use(const(Shader) shader = null)
        {
            if(shader is null)
                sfShader_bind(null);
            else
                sfShader_bind(shader.handle);
        }

        /++
         + Sets the value of a uniform variable.
         + 
         + Assertions:
         +  $(P `Args` must be supported.)
         +  $(P `name` can only be up to 254 characters long.)
         + 
         + Params:
         +  name  = The name of the uniform to set.
         +  value = The value to give the unform. It is advised to read over the function to see which parameters
         +          are supported.
         + ++/
        void setUniform(Args...)(string name, Args value)
        {
            import std.typecons : AliasSeq;

            static if(is(Args == AliasSeq!(float)))                           alias func = sfShader_setFloatParameter;
            else static if(is(Args == AliasSeq!(float, float)))               alias func = sfShader_setFloat2Parameter;
            else static if(is(Args == AliasSeq!(float, float, float)))        alias func = sfShader_setFloat3Parameter;
            else static if(is(Args == AliasSeq!(float, float, float, float))) alias func = sfShader_setFloat4Parameter;
            else static if(is(Args == AliasSeq!(Vector2f)))
            {
                alias func = sfShader_setVector2Parameter;
                auto  vect = sfVector2f(value[0].x, value[0].y);
            }
            else static if(is(Args == AliasSeq!(Vector3f)))
            {
                alias func = sfShader_setVector3Parameter;
                auto  vect = sfVector3f(value[0].x, value[0].y, value[0].z);
            }
            else
                static assert(false, "The parameters " ~ Args.stringof ~ " are not supported.");
                
            assert(name.length <= 254, "The name is too long");

            char[256] buffer;
            buffer[0..name.length] = name;
            buffer[name.length]    = '\0';

            static if(is(Args == AliasSeq!Vector2f) || is(Args == AliasSeq!Vector3f))
                func(this.handle, buffer.ptr, vect);
            else
                func(this.handle, buffer.ptr, value);
        }
        version(unittest)
        {
            // Some test instansiations.
            alias suf   = setUniform!float;
            alias suff  = setUniform!(float,float);
            alias suv3f = setUniform!Vector3f;
        }

        /++
         + Returns:
         +  The shader's handle.
         ++/
        @property @safe @nogc
        inout(Handle) handle() nothrow pure inout
        out(output)
        {
            assert(output !is null, "Attempted to use a null shader handle.");
        }
        body
        {
            return this._handle;
        }
    }
}

/++
 + Describes a sprite that can be drawn on screen.
 ++/
final class Sprite : ICacheable
{
    /++
     + An alias to the type used as the sprite's handle.
     ++/
    alias Handle = sfSprite*;

    private
    {
        Handle  _handle;
        Texture _texture;
        bool    _visible;
    }

    public
    {
        ~this()
        {
            if(this._handle !is null)
            {
                tracef("[Destroying Sprite with handle of %s]", this.handle);
                sfSprite_destroy(this.handle);
            }
        }

        /++
         + Creates a new sprite.
         +
         + Notes:
         +  `theAllocator` is used to allocate the sprite.
         +
         + Params:
         +  texture     = The `Texture` to use for the sprite.
         +  position    = The sprite's position.
         +  textureRect = Which part of the texture to actually use.
         +                Use `IntRect.empty` for the entire texture.
         +
         + Returns:
         +  A new `Sprite`
         ++/
        static Sprite create(Texture texture, Vector2f position = Vector2f(0), IntRect textureRect = IntRect.empty)
        out(output)
        {
            assert(output !is null, "No sprite was made.");
        }
        body
        {
            tracef("[Creating Sprite]");
            auto sprite = theAllocator.make!Sprite;
            scope(failure) theAllocator.dispose(sprite);
            sprite._handle     = sfSprite_create();
            sprite.texture     = texture;
            sprite.position    = position;
            sprite.textureRect = textureRect;
            sprite.visible     = true;

            tracef("[Sprite Handle = %s]", sprite.handle);

            return sprite;
        }

        /++
         + Disposes of a `Sprite` created by `Sprite.create`.
         + 
         + Notes:
         +  The `sprite` $(B must have been created by `Sprite.create`).
         + 
         + Params:
         +  sprite = The sprite to dispose of.
         +           The referenced passed through is then set to `null`.
         + ++/
        static void dispose(ref Sprite sprite)
        {
            if(sprite !is null)
            {
                theAllocator.dispose(sprite);
                sprite = null;
            }
        }

        /++
         + Moves the sprite by an offset.
         + 
         + Params:
         +  offset = The offset to move the sprite by.
         + ++/
        @property @trusted @nogc
        void move(Vector2f offset) nothrow
        {
            sfSprite_move(this.handle, offset.asNativeVector2!float);
        }

        /++
         + Sets the sprite's texture rectangle, which is the part of the sprite's texture to use when rendering.
         +
         + Params:
         +  rect = The new texture rectangle.
         +         If `rect` is `IntRect.empty` then the entire texture is used.
         ++/
        @property @trusted @nogc
        void textureRect(IntRect rect) nothrow
        {
            if(rect == IntRect.empty)
            {
                auto size = this.texture.size;
                rect      = IntRect(0, 0, size.x, size.y);
            }

            sfSprite_setTextureRect(this.handle, rect.asNative);
        }

        /++
         + Notes:
         +  The returned rectangle's `position` will be the same as `Sprite.position`.
         +  The returned rectangle's `size` will be the same as `Sprite.textureRect`.
         + 
         + Returns:
         +  A `FloatRect` representing the position and size of the Sprite.
         + ++/
        @property @safe @nogc
        FloatRect bounds() nothrow const
        {
            FloatRect rect;
            auto      size = this.textureRect.size;
            rect.position  = this.position;
            rect.size      = size.asVector2!float;

            return rect;
        }

        /++
         + Returns:
         +  What part of the texture the sprite's using.
         ++/
        @property @trusted @nogc
        IntRect textureRect() nothrow const
        {
            return IntRect.fromNative(sfSprite_getTextureRect(this.handle));
        }

        /++
         + Sets the sprite's position.
         + 
         + Params:
         +  pos = The sprite's new position.
         ++/
        @property @trusted @nogc
        void position(Vector2f pos) nothrow
        {
            sfSprite_setPosition(this.handle, pos.asNativeVector2!float);
        }

        /++
         + Returns:
         +  The sprite's position.
         ++/
        @property @trusted @nogc
        Vector2f position() nothrow const
        {
            auto vect = sfSprite_getPosition(this.handle);
            return Vector2f(vect.x, vect.y);
        }

        /++
         + Sets the `Texture` that the sprite uses.
         +
         + Assertions:
         +  `text` must not be `null`.
         +
         + Notes:
         +  $(P This property will reset the texture rect for the sprite.)
         +  $(P A reference to `text` is stored by the sprite.)
         +
         + Params:
         +  text = The texture to use.
         ++/
        @property @trusted
        void texture(Texture text)
        {
            assert(text !is null, "The texture given is null.");
            sfSprite_setTexture(this.handle, text.handle, true);
            this._texture = text;
        }

        /++
         + Returns:
         +  The `Texture` being used by this sprite.
         ++/
        @property @safe @nogc
        inout(Texture) texture() nothrow pure inout
        out(output)
        {
            assert(output !is null);
        }
        body
        {
            return this._texture;
        }

        /++
         + Sets whether the sprite is visible or not.
         +
         + Params:
         +  vis = Whether the sprite is visible.
         ++/
        @property @safe @nogc
        void visible(bool vis) nothrow
        {
            this._visible = vis;
        }

        /++
         + Returns:
         +  `true` if the sprite is visible.
         +  `false` otherwise.
         ++/
        @property @safe @nogc
        bool visible() nothrow const
        {
            return this._visible;
        }

        /++
         + Sets the Sprite's colour.
         +
         + Assertions:
         +  `col` must pass `checkColour`.
         + 
         + Params:
         +  col = The colour to use.
         + ++/
        @property @trusted @nogc
        void colour(Colour col) nothrow
        {
            sfSprite_setColor(this.handle, col.asNativeColour);
        }

        /++
         + Returns:
         +  The sprite's colour.
         + ++/
        @property @trusted @nogc
        Colour colour() nothrow const
        {
            auto col = sfSprite_getColor(this.handle);
            return Colour(col.r, col.g, col.b, col.a);
        }

        /++
         + Returns:
         +  The `Sprite`'s handle.
         ++/
        @property @safe @nogc
        inout(Handle) handle() nothrow pure inout
        out(output)
        {
            assert(output !is null, "Attempted to use a null sprite handle.");
        }
        body
        {
            return this._handle;
        }
    }
}

/++
 + Contains a texture that can be given to something to render with.
 ++/
final class Texture : ICacheable
{
    /++
     + An alias to the type used as the texture's handle.
     ++/
    alias Handle = sfTexture*;

    private
    {
        Handle _handle;
    }

    public
    {
        ~this()
        {
            if(this._handle !is null)
            {
                tracef("[Destroying Texture with handle of %s]", this.handle);
                sfTexture_destroy(this.handle);
            }
        }

        /++
         + Loads a `Texture` from a file.
         +
         + Notes:
         +  `theAllocator` is used to allocate the texture.
         +
         + Exceptions:
         +  `FileException` if `file` doesn't point to a file.
         +  `GraphicsException` if the image couldn't be loaded.
         +
         + Params:
         +  file = The path to the file to load.
         +
         + Returns:
         +  The `Texture` that was loaded from `file`.
         ++/
        @trusted
        static Texture fromFile(in char[] file)
        {
            import std.path          : asNormalizedPath;
            import std.file          : exists, FileException;
            import jaster.containers : DynamicArray;

            DynamicArray!char path;
            path.reserve(file.length + 1);
            path ~= file.asNormalizedPath;
            path ~= '\0';

            // This *does* use the GC, but the GC-using parts can be disabled via `sharedLogger.logLevel = SomeLogLevelBiggerthanTrace`
            // So for debugging it's fine.
            tracef("[Loading Texture from file '%s']", path.range);
            enforce(path.range.exists, new FileException(path, "Unable to load texture"));

            auto texture    = theAllocator.make!Texture();
            texture._handle = sfTexture_createFromFile(path.range.ptr, null);
            scope(failure) theAllocator.dispose(texture);

            enforce(texture._handle !is null, new GraphicsException("Unable to load texture"));

            return texture;
        }

        /++
         + Loads a `Texture` from memory.
         +
         + Notes: 
         +  `theAllocator` is used to allocate the texture.
         +
         + Exceptions:
         +  `GraphicsException` if the texture couldn't be loaded.
         +
         + Params:
         +  data = The bytes making up the texture.
         +
         + Returns:
         +  The `Texture` that was loaded from `data`.
         + ++/
        @trusted
        static Texture fromMemory(in ubyte[] data)
        {
            trace("[Loading Texture from memory]");
            auto texture    = theAllocator.make!Texture();
            texture._handle = sfTexture_createFromMemory(data.ptr, data.length, null);
            scope(failure) theAllocator.dispose(texture);

            enforce(texture._handle !is null, new GraphicsException("Unable to load texture"));
            return texture;
        }

        /++
         + Disposes of a `Texture` created by `fromMemory` or `fromFile`.
         + 
         + Notes:
         +  The `texture` $(B must have been created by one of the mentioned functions).
         + 
         + Params:
         +  texture = The texture to dispose of.
         +            The referenced passed through is then set to `null`.
         + ++/
        static void dispose(ref Texture texture)
        {
            if(texture !is null)
            {
                theAllocator.dispose(texture);
                texture = null;
            }
        }

        /++
         + Returns:
         +  The size of the texture.
         ++/
        @property @trusted @nogc
        Vector2u size() nothrow const
        {
            auto vect = sfTexture_getSize(this.handle);
            return Vector2u(vect.x, vect.y);
        }

        /++
         + Returns:
         +  The `Texture`'s handle.
         ++/
        @property @safe @nogc
        inout(Handle) handle() nothrow pure inout
        out(output)
        {
            assert(output !is null, "Attempted to use a null texture handle.");
        }
        body
        {
            return this._handle;
        }
    }
}

/++
 + Describes a view, which is used to render objects to only a specific portion of the screen.
 +
 + Notes:
 +  Unlike `Sprite` and `Texture`, it's recommended that a `View` is allocated with the GC, since very few
 +  are likely to be made meaning the GC won't throw a fit.
 + ++/
final class View : ICacheable
{
    /// The type used as the view's handle.
    alias Handle = sfView*;

    private
    {
        Handle _handle;
    }

    public
    {
        /++
         + Creates a new `View` that is created from a rectangle.
         + 
         + Notes:
         +  $(P Please see the documentation for `View.viewport` on what `rect`'s values should be.)
         +  $(P `theAllocator` is used to allocate the view)
         + 
         + Assertions:
         +  An assert is failed if the view couldn't be created for some reason.
         + 
         + Params:
         +  rect = The rectangle that describes the view.
         + ++/
        @trusted
        static View create(FloatRect rect = FloatRect(0, 0, 1, 1))
        {
            auto view    = theAllocator.make!View;
            view._handle = sfView_createFromRect(rect.asNative);
            scope(failure) theAllocator.dispose(view);

            assert(view._handle !is null);

            return view;
        }

        /++
         + Disposes of a `View` created by `View.create` or `View.copy`.
         + 
         + Notes:
         +  The `view` $(B must have been created by one of the mentioned functions).
         + 
         + Params:
         +  view = The view to dispose of.
         +         The referenced passed through is then set to `null`.
         + ++/
        static void dispose(ref View view)
        {
            if(view !is null)
            {
                theAllocator.dispose(view);
                view = null;
            }
        }

        ~this()
        {
            if(this._handle !is null)
            {
                sfView_destroy(this._handle);
                this._handle = null;
            }
        }

        /++
         + Creates a copy of the View.
         + 
         + Notes:
         +  `theAllocator` is used to allocate the copy.
         +
         + Returns:
         +  A copy of the View.
         + ++/
        @trusted
        View copy() const
        {
            auto view    = theAllocator.make!View;
            view._handle = sfView_copy(this.handle);

            return view;
        }

        /++
         + Moves the view by an offset.
         + 
         + Params:
         +  offset = The offset to move the view by.
         + ++/
        @trusted @nogc
        void move(Vector2f offset) nothrow
        {
            sfView_move(this.handle, offset.asNativeVector2!float);
        }

        /++
         + Rotates the view.
         + 
         + Params:
         +  rot = The angle to rotate by, in degrees.
         + ++/
        @trusted @nogc
        void rotate(float rot) nothrow
        {
            sfView_rotate(this.handle, rot);
        }

        /++
         + Sets the center of the view.
         + 
         + Params:
         +  center_ = The new center of the view.
         + ++/
        @property @trusted @nogc
        void center(Vector2f center_) nothrow
        {
            sfView_setCenter(this.handle, center_.asNativeVector2!float);
        }

        /++
         + Returns:
         +  The center of the view.
         + ++/
        @property @trusted @nogc
        Vector2f center() nothrow const
        {
            auto vect = sfView_getCenter(this.handle);
            return Vector2f(vect.x, vect.y);
        }

        /++
         + Sets the rotation of the view.
         + 
         + Params:
         +  rot = The rotation of the view in degrees.
         + ++/
        @property @trusted @nogc
        void rotation(float rot) nothrow
        {
            sfView_setRotation(this.handle, rot);
        }

        /++
         + Returns:
         +  The rotation of the view in degrees.
         + ++/
        @property @trusted @nogc
        float rotation() nothrow const
        {
            return sfView_getRotation(this.handle);
        }

        /++
         + Sets the size of the view.
         + 
         + Params:
         +  size_ = The new size of the view.
         + ++/
        @property @trusted @nogc
        void size(Vector2f size_) nothrow
        {
            sfView_setSize(this.handle, size_.asNativeVector2!float);
        }

        /++
         + Returns:
         +  The size of the view.
         + ++/
        @property @trusted @nogc
        Vector2f size() nothrow const
        {
            auto vect = sfView_getSize(this.handle);
            return Vector2f(vect.x, vect.y);
        }

        /++
         + Sets the viewport of the view from a rectangle.
         + 
         + Notes:
         +  The viewport is what part of the screen the view's contents are displayed.
         +  The range for each value is between 0 and 1, so a `FloatRect(0, 0, 0.5f, 1.0f)` would display on the left
         +  half of the screen.
         + 
         + Params:
         +  rect = The rectangle to set the view to.
         + ++/
        @property @trusted @nogc
        void viewport(FloatRect rect) nothrow
        {
            sfView_setViewport(this.handle, rect.asNative);
        }

        /++
         + Returns:
         +  The viewport.
         + ++/
        @property @trusted @nogc
        FloatRect viewport() nothrow const
        {
            return FloatRect.fromNative(sfView_getViewport(this.handle));
        }

        /++
         + Returns:
         +  The handle for the View.
         + ++/
        @property @safe @nogc
        inout(Handle) handle() nothrow pure inout
        out(output)
        {
            assert(output !is null, "Attempted to use a null viewport handle.");
        }
        body
        {
            return this._handle;
        }
    }
}

/++
 + Contains a font, which can be used alongside `Text` to render text to the screen.
 + ++/
final class Font : ICacheable
{
    import jaster.containers;

    /// The type used as the font's handle.
    alias Handle = sfFont*;

    private
    {
        Handle             _handle;
        DynamicArray!ubyte _data;
    }

    public
    {
        ~this()
        {
            tracef("[Destroying font with handle of '%s']", this._handle);

            if(this._handle !is null)
                sfFont_destroy(this._handle);
        }

        /++
         + Creates a font from a file.
         + 
         + Notes:
         +  `theAllocator` is used to allocate the font.
         + 
         + Exceptions:
         +  $(P `FileException` if `file` doesn't exist.)
         +  $(P `GraphicsException` if a font couldn't be loaded from `file`.)
         + 
         + Params:
         +  file = The file to load the font from.
         + 
         + Returns:
         +  The font loaded from `file`.
         + ++/
        @trusted
        static Font fromFile(string file)
        out(output)
        {
            assert(output !is null, "Exceptions exist for a reason. (Says the coder who litters asserts everywhere)");
        }
        body
        {
            import std.path : asNormalizedPath;
            import std.file : exists, FileException;

            DynamicArray!char path;
            path.reserve(file.length + 1);
            path ~= file.asNormalizedPath;
            path ~= '\0';

            tracef("[Loading font from file '%s']", path.range);
            enforce(path.range.exists, new FileException(path.range, "Cannot load Font"));

            auto font    = theAllocator.make!Font;
            font._handle = sfFont_createFromFile(path.range.ptr);
            scope(failure) theAllocator.dispose(font);

            enforce(font._handle !is null, new GraphicsException("Unable to load font"));
            tracef("[Font handle = %s]", font._handle);

            return font;
        }

        /++
         + Loads a font from memory.
         + 
         + Notes:
         +  $(P The contents of `bytes` is copied into an internal buffer.)
         +  $(P `theAllocator` is used to allocate the `Font`, and `Mallocator` is used for the internal buffer.)
         + 
         + Exceptions:
         +  `GraphicsException` if no `Font` could be loaded from `bytes`.
         + 
         + Params:
         +  bytes = The bytes making up the font.
         + 
         + Returns:
         +  The font created from `bytes`.
         + ++/
        @trusted
        static Font fromMemory(const ubyte[] bytes)
        out(output)
        {
            assert(output !is null, "Exceptions exist for a reason.");
        }
        body
        {
            tracef("[Loading font from memory]");

            auto font    = theAllocator.make!Font;
            font._data  ~= bytes;
            font._handle = sfFont_createFromMemory(font._data.range.ptr, font._data.length);
            scope(failure) theAllocator.dispose(font);

            enforce(font._handle !is null, new GraphicsException("Unable to load font from memory."));
            tracef("[Font handle = %s]", font._handle);

            return font;
        }

        /++
         + Disposes of and deallocates a font.
         + 
         + Notes:
         +  `theAllocator` is used to deallocate the font.
         + 
         + Params:
         +  font = A reference to the `Font` to dispose of and deallocate.
         +         If the font is `null` then nothing happens.
         + ++/
        @trusted
        static void dispose(ref Font font)
        {
            if(font !is null)
            {
                theAllocator.dispose(font);
                font = null;
            }
        }

        /++
         + Returns:
         +  The `Handle` this font uses.
         + ++/
        @property @safe @nogc
        inout(Handle) handle() nothrow inout
        out(output)
        {
            assert(output !is null, "Attempted to use a null font handle.");
        }
        body
        {
            return this._handle;
        }

        /++
         + Notes:
         +  Unless something goes wrong, this font should *always* be valid for use.
         + 
         + Returns:
         +  A font to be used for debugging.
         + ++/
        @property @trusted
        static const(Font) debugFont()
        {
            static Font instance;
            if(instance is null)
                instance = Font.fromMemory(_debugFontBytes);

            return instance;
        }
    }
}

/++
 + A class which is used to render text to the screen.
 + ++/
final class Text : ICacheable
{
    import std.traits : isSomeChar;
    import std.utf    : byDchar;
    import jaster.containers;

    alias Handle = sfText*;

    private
    {
        DynamicArray!dchar _text;
        Handle             _handle;
    }

    public
    {
        ~this()
        {
            tracef("[Destroying Text with handle of %s]", this._handle);
            if(this._handle !is null)
                sfText_destroy(this._handle);
        }

        /++
         + Creates a new `Text`.
         + 
         + Notes:
         +  `theAllocator` is used to allocate the `Text`.
         + 
         + Assertions:
         +  `font` must not be `null`.
         + 
         + Params:
         +  C        = The char type used for the text. See `Text.text`[set].
         +  font     = The `Font` to use.
         +  text     = The text to render.
         +  position = The position to render the text at.
         +  charSize = The size of the characters when rendering.
         +  colour   = The colour of the text when rendering.
         + 
         + See_Also:
         +  `Text.text`[set] for information on what `text` is.
         + ++/
        @trusted
        static Text create(C)(const Font font, const(C)[] text = "", const Vector2f position = Vector2f(0),
                              const uint charSize = 16, const Colour colour = Colour(0, 0, 0, 255))
        if(isSomeChar!C)
        {
            assert(font !is null, "Attempted to use a null font.");
            tracef("[Creating a Text, using char type '%s', and font with handle '%s'.]", C.stringof, font.handle);

            auto obj = theAllocator.make!Text;
            scope(failure) theAllocator.dispose(obj);

            obj._handle = sfText_create();
            assert(obj._handle !is null, "o_o It's null");
            tracef("[Text Handle = %s]", obj._handle);

            obj.text     = text;
            obj.font     = font;
            obj.position = position;
            obj.charSize = charSize;
            obj.colour   = colour;

            return obj;
        }
        version(Engine_Tests)
        {
            alias testCreate = create!char;
        }

        /++
         + Disposes of and deallocates a `Text`.
         + 
         + Notes:
         +  `theAllocator` is used to deallocate the text.
         + 
         + Params:
         +  text = A reference to the `Text` to dispose of and deallocate.
         +         If the font is `null` then nothing happens.
         + ++/
        static void dispose(ref Text text)
        {
            if(text !is null)
            {
                theAllocator.dispose(text);
                text = null;
            }
        }

        /++
         + Sets the text to draw.
         + 
         + Notes:
         +  $(P A copy of `txt` is made, so it is safe to deallocate it afterwards.)
         +  $(P `std.utf.byDchar` is used to convert `txt` into a `dstring` behind the scenes.)
         + 
         + Params:
         +  txt = The text to draw.
         + ++/
        @property @trusted @nogc
        void text(C)(const(C)[] txt) nothrow
        if(isSomeChar!C)
        {
            this._text.length = 0;
            this._text       ~= txt.byDchar;
            this._text       ~= '\0';
            sfText_setUnicodeString(this.handle, this._text.range.ptr);
        }
        version(Engine_Tests)
        {
            private alias testText = text!char;
        }

        /++
         + Notes:
         +  $(P The return value of this function is a direct slice to the `Text`'s text.)
         +  $(P This means that $(B no) references should be kept around after any changes to the `Text`'s text
         +      is made, as it may cause a crash, so it's advised to create a copy of the text if it needs to be stored.)
         + 
         + Returns:
         +  The text being used when drawing this `Text`.
         + ++/
        @property @nogc
        const(dchar)[] text() nothrow //const
        {
            return this._text.range;
        }

        /++
         + Sets the position of where to render the text.
         + 
         + Params:
         +  pos = Where the text should be rendered.
         + ++/
        @property @trusted @nogc
        void position(const Vector2f pos) nothrow
        {
            sfText_setPosition(this.handle, pos.asNativeVector2!float);
        }

        /++
         + Returns:
         +  The position of where the text is to be rendered.
         + ++/
        @property @trusted @nogc
        Vector2f position() nothrow const
        {
            auto vect = sfText_getPosition(this.handle);
            return Vector2f(vect.x, vect.y);
        }

        /++
         + Sets the font to be used when rendering the text.
         + 
         + Assertions:
         +  `font` must not be `null`.
         + 
         + Notes:
         +  `font` must not be disposed of while there are `Text`s still using it.
         + 
         + Params:
         +  font = The `Font` to use.
         + ++/
        @property @trusted @nogc
        void font(const Font font) nothrow
        {
            assert(font !is null, "Attempted to use a null font.");
            sfText_setFont(this.handle, font.handle);
        }

        /++
         + Sets the colour of the text.
         + 
         + Params:
         +  col = The `Colour` to use.
         + ++/
        @property @trusted @nogc
        void colour(const Colour col) nothrow
        {
            sfText_setColor(this.handle, col.asNativeColour);
        }

        /++
         + Returns:
         +  The `Colour` of the text.
         + ++/
        @property @trusted @nogc
        Colour colour() nothrow const
        {
            auto col = sfText_getColor(this.handle);
            return Colour(col.r, col.g, col.b, col.a);
        }

        /++
         + Sets the size of the characters.
         + 
         + Params:
         +  siz = The size of the characters.
         + ++/
        @property @trusted @nogc
        void charSize(uint siz) nothrow
        {
            sfText_setCharacterSize(this.handle, siz);
        }

        /++
         + Returns:
         +  The size of the characters.
         + ++/
        @property @trusted @nogc
        uint charSize() nothrow const
        {
            return sfText_getCharacterSize(this.handle);
        }

        /++
         + Returns:
         +  The size of the text when rendered.
         + ++/
        @property @trusted @nogc
        Vector2f size() nothrow const
        {
            return FloatRect.fromNative(sfText_getGlobalBounds(this.handle)).size;
        }

        /++
         + Returns:
         +  The `Handle` being used by this `Text`.
         + ++/
        @property @safe @nogc
        inout(Handle) handle() nothrow inout
        out(output)
        {
            assert(output !is null, "Attempted to use null Text handle.");
        }
        body
        {
            return this._handle;
        }
    }
}

/++
 + Describes a drawable rectangle.
 + ++/
final class RectangleShape : ICacheable
{
    /// The type used as the handle.
    alias Handle = sfRectangleShape*;

    private
    {
        Handle  _handle;
    }

    public
    {
        ~this()
        {
            tracef("[Destroying rectangle shape with handle of %s]", this._handle);
            if(this._handle !is null)
                sfRectangleShape_destroy(this._handle);
        }

        /++
         + Creates a new `RectangleShape`.
         + 
         + Notes:
         +  `theAllocator` is used to allocate the object.
         + 
         + Params:
         +  rect            = The `Rectangle` describing the position and size of the shape.
         +  fillColour      = The `Colour` to use for the inside of the Rectangle.
         +  thickness       = How thick the rectangle's outline is.
         +  outlineColour   = The `Colour` of the shape's outline.
         + 
         + Returns:
         +  The newly made rectangle shape.
         + ++/
        @trusted
        static RectangleShape create(Rect)(const Rect rect,           const Colour fillColour    = Colour(0, 0, 0, 255),
                                           const float thickness = 0, const Colour outlineColour = Colour(0, 0, 0, 255))
        if(isRectangle!Rect)
        {
            auto shape      = theAllocator.make!RectangleShape;
            shape._handle   = sfRectangleShape_create();
            scope(failure) theAllocator.dispose(shape);

            assert(shape._handle !is null, "For some reason the handle wasn't made.");

            tracef("[Creating rectangle shape with handle of %s]", shape._handle);
            shape.position      = rect.position;
            shape.size          = rect.size;
            shape.fillColour    = fillColour;
            shape.thickness     = thickness;
            shape.outlineColour = outlineColour;

            return shape;
        }

        /++
         + Disposes of and deallocates a `RectangleShape`.
         + 
         + Notes:
         +  `theAllocator` is used to deallocate the shape.
         + 
         + Params:
         +  shape = A reference to the `RectangleShape` to dispose of and deallocate.
         +          If the shape is `null` then nothing happens.
         + ++/
        @trusted
        static void dispose(ref RectangleShape shape)
        {
            if(shape !is null)
            {
                theAllocator.dispose(shape);
                shape = null;
            }
        }

        /++
         + Sets the position of the shape.
         + 
         + Notes:
         +  While this function accepts any 2D `Vector` type, the position will always end up as a `Vector2f`.
         + 
         + Params:
         +  pos = The new position.
         + ++/
        @property
        void position(Vect)(const Vect pos)
        if(isVector!Vect && Vect.dimension == 2)
        {
            sfRectangleShape_setPosition(this.handle, pos.asNativeVector2!float);
        }

        /++
         + Returns:
         +  The position of the shape.
         + ++/
        @property @trusted @nogc
        Vector2f position() nothrow const
        {
            auto pos = sfRectangleShape_getPosition(this.handle);
            return Vector2f(pos.x, pos.y);
        }

        /++
         + Sets the size of the shape.
         + 
         + Notes:
         +  While this function accepts any 2D `Vector` type, the size will always end up as a `Vector2f`.
         + 
         + Params:
         +  siz = The new size.
         + ++/
        @property
        void size(Vect)(const Vect siz)
        if(isVector!Vect && Vect.dimension == 2)
        {
            sfRectangleShape_setSize(this.handle, size.asNativeVector2!float);
        }

        /++
         + Returns:
         +  The size of the shape.
         + ++/
        @property @trusted @nogc
        Vector2f size() nothrow const
        {
            auto siz = sfRectangleShape_getSize(this.handle);
            return Vector2f(siz.x, siz.y);
        }

        /++
         + Sets the colour for the inside of the rectangle.
         + 
         + Params:
         +  col = The `Colour` to use.
         + ++/
        @property @trusted @nogc
        void fillColour(const Colour col) nothrow
        {
            sfRectangleShape_setFillColor(this.handle, col.asNativeColour);
        }

        /++
         + Returns:
         +  The `Colour` for the inside of the rectangle.
         + ++/
        @property @trusted @nogc
        Colour fillColour() nothrow const
        {
            auto col = sfRectangleShape_getFillColor(this.handle);
            return Colour(col.r, col.g, col.b, col.a);
        }

        /++
         + Sets how thick the outline of the shape is.
         + 
         + Params:
         +  thick = The thickness.
         + ++/
        @property @trusted @nogc
        void thickness(const float thick) nothrow
        {
            sfRectangleShape_setOutlineThickness(this.handle, thick);
        }

        /++
         + Returns:
         +  How thick the outline of the shape is.
         + ++/
        @property @trusted @nogc
        float thickness() nothrow const
        {
            return sfRectangleShape_getOutlineThickness(this.handle);
        }

        /++
         + Sets the colour for the outline of the shape.
         + 
         + Params:
         +  colour = The `Colour` to use.
         + ++/
        @property @trusted @nogc
        void outlineColour(const Colour colour) nothrow
        {
            sfRectangleShape_setOutlineColor(this.handle, colour.asNativeColour);
        }

        /++
         + Returns:
         +  The `Colour` for the outline of the shape.
         + ++/
        @property @trusted @nogc
        Colour outlineColour() nothrow const
        {
            auto col = sfRectangleShape_getOutlineColor(this.handle);
            return Colour(col.r, col.g, col.b, col.a);
        }

        /++
         + Returns:
         +  The `Handle` for this rectangle shape.
         + ++/
        @property @safe @nogc
        inout(Handle) handle() nothrow inout
        {
            return this._handle;
        }
    }
}

/++
 + Thrown whenever something regarding graphics goes wrong.
 + ++/
class GraphicsException : Exception
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
/// 
module jengine.thirdparty;

public
{
    import derelict.opengl.gl, derelict.opengl.impl, derelict.opengl.types, derelict.sdl2.sdl;
}

mixin glLoaders!(GLVersion.gl40);

/// Loads all of the third-party libraries
void loadLibraries()
{
    import std.experimental.logger, std.exception;

    trace("[Loading DerelictGL3]");
    DerelictGL3.load();

    trace("[Loading SDL2]");
    DerelictSDL2.load();
    enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0, new Exception("Unable to initialise SDL: " ~ getSDLError()));
}

/++
 + Gets the last error SDL has thrown.
 + ++/
@trusted
package string getSDLError()
{
    import std.string;
    return SDL_GetError().fromStringz.idup;
}
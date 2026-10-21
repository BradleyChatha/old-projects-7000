/// 
module jengine.thirdparty;

public
{
    import derelict.bgfx.bgfx, derelict.sdl2.sdl;
}

/// Loads all of the third-party libraries
void loadLibraries()
{
    import std.experimental.logger, std.exception;

    trace("[Loading BGFX]");
    DerelictBgfx.load();

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
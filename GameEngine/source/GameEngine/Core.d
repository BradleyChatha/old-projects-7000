module GameEngine.Core;

private
{
    import  std.math,
            std.random,
            std.typecons,
            std.stdio;

    import  derelict.util.loader;

    import  gfm.logger,
            gfm.sdl2,
            gfm.opengl,
            gfm.math;
}

/++
+   Contains the main variables and is responible for initing systems and uniniting them.
+   Holds the main references to SDL and OpenGL for the rest of the program.
++/
class Core
{
public:

    /++
    +   Inits the SDL and Opengl. Gets SDL ready for use.
    ++/
    this()
    {
        this.log = new ConsoleLogger();

        // load dynamic libraries
        this.sdl= scoped!SDL2(log, SharedLibVersion(2, 0, 0));
        this.gl = scoped!OpenGL(log);

        // You have to initialize each SDL subsystem you want by hand
        this.sdl.subSystemInit(SDL_INIT_VIDEO);
        this.sdl.subSystemInit(SDL_INIT_EVENTS);

        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    }

    /++
    +   Gets the reference to the SDL context.
    +   Retruns a SDL reference.
    ++/
    SDL2* GetSDL()
    {
        return &this.sdl;
    }

    /++
    +   Gets the reference to the OpenGL context.
    +   Returns a OpenGL reference.
    ++/
    OpenGL* GetGL()
    {
        return &this.gl;
    }

    /++
    +   Gets the OpenGL ready for use, by reloading once there is a OpenGL context window avilable.
    ++/
    void EnableGL()
    {
        this.gl.reload();
        this.gl.redirectDebugOutput();
    }

private:
    //The logger
    ConsoleLogger log;
    //The SDL reference
    SDL2 sdl;
    //The OpenGL reference
    OpenGL gl;
}
module GameEngine.Core;

private
{
    import  std.typecons;

    import  derelict.util.loader;

    import  gfm.logger,
            gfm.sdl2,
            gfm.opengl,
            gfm.math;
}

class Core
{
public:
    this()
    {
        log = new ConsoleLogger();

        this.sdl = scoped!SDL2(log, SharedLibVersion(2, 0, 0));
        this.gl = scoped!OpenGL(log);
    }
private:
    ConsoleLogger log;
    SDL2 sdl;
    OpenGL gl;
}
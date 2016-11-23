/// 
module jengine.thirdparty;

public
{
    import derelict.opengl.gl, derelict.opengl.impl, derelict.opengl.types, derelict.glfw3;
}

mixin glLoaders!(GLVersion.gl40);

/// Loads all of the third-party libraries
void loadLibraries()
{
    import std.experimental.logger;

    trace("[Loading DerelictGL3]");
    DerelictGL3.load();

    trace("[Loading GLFW3]");
    DerelictGLFW3.load();
}
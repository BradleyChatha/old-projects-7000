module sfml;

public
{
    import derelict.sfml2.graphics, derelict.sfml2.system, derelict.sfml2.window;
}

void loadSFML()
{
    DerelictSFML2System.load();
    DerelictSFML2Graphics.load();
    DerelictSFML2Window.load();
}
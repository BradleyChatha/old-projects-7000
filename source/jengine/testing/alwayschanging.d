module jengine.testing.alwayschanging;

private
{
    import jengine.core, jengine.graphics;
}

// This test is used to test newer features, before they get their own standalone test.
void always_changing_test()
{
    auto window = new Window("Testtttttterr", Vector2u(720, 620));
    scope(exit) window.onUninit();

    window.renderer.reset(window.size, Renderer.ResetFlags.VSync);
    window.renderer.debugFlags = Renderer.DebugFlags.Text;

    // Uncomment to run test properly
    //while(!window.shouldClose)
    {
        window.input.processEvents;
        window.renderer.renderDebugText(Vector2u(0), Renderer.DebugColour.Green, "This is some example text!");
        window.renderer.renderFrame();
    }
}
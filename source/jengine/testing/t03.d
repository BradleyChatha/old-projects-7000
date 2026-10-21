module jengine.testing.t03;

import std.typecons : Yes, No;
import jengine.core.engine,
       jengine.core.post,
       jengine.core.maths,
       jengine.graphics.window;

version(none):
class T03 : App
{
    private
    {
        uint phase = 1;
    }

    public
    {
        override void onInit(Engine engine)
        {
            super.onInit(engine);
        }

        override void onUninit()
        {
            super.onUninit();
        }

        override void onUpdate(double delta)
        {
            import std.experimental.logger;

            // Manufacture an Engine.onUpdate, with a value that phase 1 is looking for.
            if(phase == 1)
            {
                trace("[Phase 1]");
                phase = 2;
                super.engine.onUpdate(400.0);
            }
            // See if the manufactured update passed the NaN value.
            else if(phase == 2)
            {
                trace("[Phase 2]");
                phase = 3;
                assert(delta == 400.0, "400.0 wasn't passed D:. Probably an issue with Engine.onUpdate");
            }
            // Make the program sleep by 0.2 seconds, so phase 4 can check it
            else if(phase == 3)
            {
                trace("[Phase 3]");

                import core.thread : Thread;
                import core.time   : msecs;
                phase = 4;
                Thread.sleep(200.msecs);
            }
            // Check the delta time for the next loop.
            else if(phase == 4)
            {
                trace("[Phase 4]");
                phase = 5;
                assert(delta >= 0.2, "Doesn't seem the delta time is working right.");
            }
            // Stop the engine, and make sure it did what it was supposed to do.
            else if(phase == 5)
            {
                trace("[Phase 5]");
                assert(super.engine.window.isOpen);
                super.engine.events.mailCommand(Engine.Events.StopGameLoop);
                assert(!super.engine.window.isOpen, "D: Doesn't seem to have worked");
            }
            else
            {
                assert(false, "A phase was skipped, or the engine didn't stop looping.");
            }
        }
    }
}

void t03()
{
    auto app    = new T03();
    auto window = new Window("Test 03", Vector2u(100, 100));
    auto engine = new Engine();

    engine.onInit(["", "--winx=340", "--winy=200"], app, window);
    scope(exit) engine.onUninit();

    assert(window.size   == Vector2u(340, 200), "Engine.handleArgs didn't work.");
    assert(engine.window == window,             "Engine.window is incorrect.");
    assert(engine.app    == app,                "Engine.app is incorrect.");

    engine.doLoop(Yes.vsync);
}
/++
 + Contains the code for the engine itself.
 + ++/
module jengine.core.engine;

private
{
    import std.experimental.logger;

    import jengine.graphics.window, jengine.graphics.renderer, jengine.core.post;
}

public
{
    import std.typecons : Flag, Yes, No;
}

/++
 + The Engine class is where everything is put together, to make something that works.
 + ++/
version(none)
final class Engine : IPostBox
{
    mixin(IPostBox.generateOnMail!Engine);

    /++
     + The events the `Engine` may post through (or look for in) it's `Engine.events` `PostOffice`.
     + ++/
    enum Events : Mail.MailTypeT
    {
        /++
         + Stops the game loop by closing the game's window.
         + 
         + Mail_Type:
         +  Any, the engine only looks for the `Mail`'s type.
         + 
         + Effects:
         +  $(P Closes the engine's window.)
         +  $(P Causes `Engine.doLoop` to return.)
         + ++/
        StopGameLoop = 1
    }

    private
    {
        App        _app;
        Window     _window;
        PostOffice _office;

        void handleArgs(string[] args, Window window)
        {
            import std.getopt;
            import jengine.core.maths;

            uint winX = window.size.x;
            uint winY = window.size.y;
            args.getopt("winx", &winX,
                        "winy", &winY);

            window.size = Vector2u(winX, winY);
        }

        @MailBox(Events.StopGameLoop)
        void onStopLoop(PostOffice, Mail)
        {
            trace("[Stopping Engine]");
            if(this._window.isOpen)
                this._window.close();
        }
    }

    public
    {
        /++
         + Initialises the engine.
         + 
         + Assertions:
         +  None of the function's parameters may be `null`.
         + 
         + Notes:
         +  This function will ensure that `app` is initialised.
         + 
         + Arguments:
         +  This is a table of all the arguments in `args` that the engine will recognise:
         +  $(TABLE
         +      $(TR
         +          $(TH Argument) $(TH Description) $(TH Example)
         +      )
         +      $(TR
         +          $(TD winx) $(TD Sets the width of the window) $(TD --winx=800)
         +      )
         +      $(TR
         +          $(TD winy) $(TD Sets the height of the window) $(TD --winy=700)
         +      )
         +  )
         + 
         + Params:
         +  args   = The program's arguments.
         +  app    = The `App` controlling the engine.
         +  window = The `Window` being used for the game.
         + +/
        void onInit(string[] args, App app, Window window)
        {
            tracef("[Initialising engine with args '%s']", args);
            assert(app    !is null, "Cannot use a null App with the engine.");
            assert(window !is null, "Cannot use a null Window with the engine.");

            this._window = window;
            this._office = new PostOffice();
            this._office.onInit(this);
            this._office.reserveTypes!Events;
            this._office.subscribe(this);

            if(!app.hasInit)
                app.onInit(this);
            this._app = app;
            
            this.handleArgs(args, window);
        }

        /++
         + Uninitialises the engine.
         + ++/
        void onUninit()
        {
            trace("[Uninitialising engine]");
            if(this._app !is null && this.app.hasInit)
            {
                this.app.onUninit();
                this._app = null;
            }

            if(this.window !is null)
            {
                this.window.onUninit();
                this._window = null;
            }

            if(this._office !is null && this._office.hasInit)
            {
                this._office.onUninit();
                this._office = null;
            }
        }

        /++
         + Updates the engine.
         + 
         + Notes:
         +  This function should never need to be called manually, use `doLoop` instead.
         + 
         + Params:
         +  delta = The time since the last frame.
         + ++/
        void onUpdate(double delta)
        {
            import std.format;
            assert(delta > 0, format("The delta time should never be negative or 0. Delta = %s", delta));
            this.app.onUpdate(delta);
        }

        /++
         + Starts the game's main loop.
         + 
         + Notes:
         +  To stop the engine from looping, either close the engine's `window`, or post a mail of type
         +  `Engine.Events.StopGameLoop`, e.g `engine.events.mailCommand(Engine.Events.StopGameLoop);`
         + 
         + Params:
         +  vsync = $(P If `Yes.vsync`, then the engine will use Vsync to limit itself.)
         +          $(P If `No.vsync`, then the engine will attempt to limit its framerate to the value of `fps`.)
         +  fps   = The desired FPS to achieve.
         + ++/
        void doLoop(Flag!"vsync" vsync, ushort fps = 60)
        {
            import std.typecons : Yes, No;
            import sfml;

            tracef("[Starting Engine loop. Vsync = %s. FPS = %s.]", vsync, fps);
            auto clock = sfClock_create();
            scope(exit) sfClock_destroy(clock);

            if(vsync)
                this.window.vsync = true;
            else
                sfRenderWindow_setFramerateLimit(this.window.handle, fps);

            auto delta = 0.1;
            while(this.window.isOpen)
            {
                this.window.input.processEvents();
                this.window.renderer.clear(Colour(255, 255, 255, 255));
                this.app.onUpdate(delta);
                this.window.display();

                // If the user-code changes whether the window uses vsync or not, update things to match up.
                if(vsync && !this.window.vsync)
                {
                    sfRenderWindow_setFramerateLimit(this.window.handle, fps);
                    vsync = No.vsync;
                }
                else if(!vsync && this.window.vsync)
                {
                    sfRenderWindow_setFramerateLimit(this.window.handle, 0);
                    vsync = Yes.vsync;
                }

                delta = sfClock_restart(clock).sfTime_asSeconds();
            }
        }

        /++
         + Assertions:
         +  The returned value must not be `null`.
         + 
         + Returns:
         +  The app currently being used by the engine.
         + ++/
        @property @safe @nogc
        inout(App) app() nothrow pure inout
        out(output)
        {
            assert(output !is null, "The app is null.");
        }
        body
        {
            return this._app;
        }

        /++
         + Returns:
         +  The `Window` being used by the game.
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
         + Description:
         +  This post office is used to talk to systems such as the `Window` and even the `Engine` itself.
         +  Some of these systems may also use this PostOffce. The game/any user-made systems can make use of this office
         +  as well.
         +
         + Returns:
         +  A `PostOffice` that can be used throughout the entire engine for whatever is needed.
         + 
         + See_Also:
         +  `Engine.Events`
         + ++/
        @property @safe @nogc
        inout(PostOffice) events() nothrow pure inout
        out(output)
        {
            assert(output !is null, "The post office is null.");
        }
        body
        {
            return this._office;
        }
    }
}

/++
 + The base class for where the game logic is created.
 + ++/
version(none)
abstract class App : IInitialisable!Engine
{
    public
    {
        // Until getSymbolsByUDA fixes a bug, this has to be public.
        Engine _engine;
    }

    public
    {
        /++
         + This is where the App should initialise itself/any sub-components.
         + 
         + Notes:
         +  `super.onInit(engine)` should be called before anything else.
         + 
         + Params:
         +  engine = The `Engine` this app is controlling.
         + ++/
        abstract override void onInit(Engine engine)
        {
            assert(engine !is null, "Cannot use a null Engine");
            this._engine = engine;
        }

        /++
         + This is where the App should uninitialise itself/any sub-components.
         + 
         + Notes:
         +  `super.onUninit()` should be called last.
         + ++/
        abstract override void onUninit()
        {
            if(this._engine !is null)
                this._engine = null;
        }

        /++
         + This is where the App should update itself.
         + 
         + Params:
         +  delta = $(P The time since the last frame.)
         +          $(P Any code involving speed should multiply the speed by `delta`, to ensure frame-independence) 
         + ++/
        abstract void onUpdate(double delta);

        /++
         + Assertions:
         +  The returned value must not be `null`.
         + 
         + Returns:
         +  The `Engine` this `App` is attached to.
         + ++/
        @property @safe @nogc
        Engine engine() nothrow pure
        out(output)
        {
            assert(output !is null, "The engine is null.");
        }
        body
        {
            return this._engine;
        }

        /++
         + Asasertions:
         +  `engine` must return non-`null` if `hasInit` returns `true.
         + 
         + Returns:
         +  `true` if the `App` has been initialsed.
         +  `false` otherwise.
         + ++/
        @property @safe @nogc
        override bool hasInit() nothrow pure
        out(output)
        {
            if(output)
                assert(this.engine !is null, "The engine is null, but the app is reporting as initialised.");
        }
        body
        {
            return this._engine !is null;
        }
    }
}

/++
 + An interface for something that can be uninitialised.
 +
 + Notes:
 +  $(P It is adivsed to not directly implement this interface, but to instead use `IInitialisable`.
 +      But of course, if the type only needs an `onUninit` function, then only use this interface.)
 +  $(P If the programmer knows objects implementing are `IInitialisable` are stored, but are stored in a way,
 +      that the "onUninit" function cannot be accessed (such as being stored as `Object`) then the object can be casted
 +      to `IUnitialisable` to access this "onUninit" function without knowing the exact instansiation of `IInitialisable` it uses.)
 + ++/
interface IUninitialisable
{
    ///
    void onUninit();
}
///
unittest
{
    class C : IInitialisable!()
    {
        bool flag = false;
        void onInit()   {}
        void onUninit() {this.flag = true;}
        bool hasInit()  {return false;} // Dummy value
    }

    // Normally, we could just call "onUninit" like usual
    auto myC = new C();
    myC.onInit();
    // Some stuff...
    myC.onUninit(); // Uninit the object once we're done.
    assert(myC.flag);

    // However, what if the object was stored as "Object"?
    myC = new C();
    myC.onInit();
    Object obj = myC;
    
    // Now how can we uninitialise the object, using "obj"?
    // Well, we just cast it to IUninitialisable
    assert(!myC.flag); // Before the uninit.
    (cast(IUninitialisable)obj).onUninit(); // Now we can still use onUninit, without having to know what the original "IInitialisable" it implemented from was.
    assert(myC.flag); // After the uninit
}

/++
 + Defines the interface for any class that provides `onInit` and `onUninit` functions.
 +
 + In the event an IInitialisable's "onUninit" function needs to be called, but the type is stored as
 + something like an "Object" or any other type, then the object can be casted to an `IUninitialisable`
 + which is a non-generic interface for providing an "onUninit" function.
 +
 + Params:
 +  OnInitParams = The types used for the parameters for class' `onInit` function.
 +                 If the `onInit` function takes no parameters, then use code such as the following -
 +                 `class C : IInitialisable!()`
 + ++/
interface IInitialisable(OnInitParams...) : IUninitialisable
{
    /++
    + Called when the class should initialise everything.
    + 
    + Assertions:
    +  `hasInit` should return `false`.
    + ++/
    void onInit(OnInitParams)
    in
    {
        assert(!this.hasInit, "Attempted to intiialise object multiple times.");
    }

    /++
    + Called when the class should uninitialise everything.
    + ++/
    void onUninit()
    in
    {
        assert(this.hasInit, "Attempted to uninitialise object multiple times.");
    }

    /++
    + Returns:
    +  Whether the class has initialised or not.
    + ++/
    @property
    bool hasInit();
}
///
unittest
{
    class C : IInitialisable!int
    {
        bool isInit = false;
        void onInit(int a) { isInit = (a == 20); }
        void onUninit()    { isInit = false; }
        bool hasInit()     { return isInit; }
    }

    auto myC = new C();
    assert(!myC.hasInit);
    myC.onInit(20);
    assert(myC.hasInit);
    myC.onUninit();
    assert(!myC.hasInit);
    myC.onInit(40);
    assert(!myC.hasInit);
}
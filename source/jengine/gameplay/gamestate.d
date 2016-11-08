/++
 + Contains code that a game might use to manage game states.
 + ++/
module jengine.gameplay.jengine;

private
{
    import std.experimental.logger, std.experimental.allocator;
    import jengine.core.engine, jengine.core.post;
    import jaster.containers;
}

/++
 + The base class for a game state.
 +
 + Game states are used as a way to split up different parts of the game.
 + For example, there may be a game state for the main menu, and then a seperate game state for the gameplay itself.
 + ++/
abstract class Gamestate : IInitialisable!GamestateManager
{
    private
    {
        GamestateManager _manager;
    }

    public
    {
        /++
         + Initialises the game state.
         +
         + Classes inheriting from `Gamestate` should make a call to `super.onInit` before anything else.
         +
         + Assertions:
         +  `manager` must not be `null`.
         +
         + Params:
         +  manager = The `GamestateManager` that will be using this game state.
         + ++/
        abstract void onInit(GamestateManager manager)
        in
        {
            assert(manager !is null, "Attempted to initialise a game state with a null manager.");
        }
        body
        {
            this._manager = manager;
        }

        /++
         + Unintialises the game state.
         +
         + Classes inheriting from `Gamestate` should make a call to `super.onUninit` at some point.
         + ++/
        abstract void onUninit()
        {
            this._manager = null;
        }

        /++
         + Called whenever the game state should update itself.
         +
         + Params:
         +  delta = The amount of seconds the last frame took.
         + ++/
        abstract void onUpdate(double delta);

        /++
         + Returns:
         +  The `GamestateManager` that this game state is registered to.
         + ++/
        @property @safe @nogc
        inout(GamestateManager) manager() nothrow inout
        out(output)
        {
            assert(output !is null, "This Gamestate has not been registered to a manager.");
        }
        body
        {
            return this._manager;
        }

        /++
         + Returns:
         +  Whether the class has initialised or not.
         + ++/
        @property @safe @nogc
        bool hasInit() nothrow pure const
        {
            return this._manager !is null;
        }
    }
}

/++
 + Used to keep track of and manage `Gamestate`s.
 +
 + Gamestates can be registered and associated with a name, and can perform certain operations with them -
 +  $(P  - There is a stack of game states, where the top-most game state is the current one)
 +  $(P  - Game states can be both pushed and popped off the stack)
 +  $(P  - Game states can also perform a "swap", which will replace the top-most gamestate with another one.
 +         This saves having to bother popping and pushing a gamestate just to change the top-most one.)
 +  $(P  - A stack-based approach allows something like the following - 
 +         [Push Main_Menu] [On button click, Push Fight_Screen] [On fight finish, Pop Fight_Screen] [Main_Menu is now top-most again])
 + ++/
final class GamestateManager : IInitialisable!Engine
{
    private
    {
        alias Map   = HashMap!(string, Gamestate);
        alias Array = DynamicArray!(Gamestate);

        Map     _states;
        Array   _stack;
        Engine  _engine;
    }

    public
    {
        /++
         + Initialises the game state manager.
         + 
         + Assertions:
         +  `engine` must not be `null`.
         +
         + Params:
         +  engine = The `Engine` being used.
         + ++/
        @trusted
        void onInit(Engine engine)
        {
            trace("[Initialising a GamestateManager]");
            assert(engine !is null, "Attempted to initialise game state manager with null engine.");
            this._engine = engine;
        }

        /++
         + Unitialises the manager and all of it's game states.
         +
         + Notes:
         +  This function will dispose of and deallocate the memory of any `Gamestate` registered.
         +  So keeping around any references to these game states is not advised.
         + ++/
        @trusted
        void onUninit()
        {
            trace("[Uninitialising a GamestateManager]");

            import std.algorithm : map, each;
            this._engine       = null;
            this._stack.length = 0;
            this._stack.shrink();

            DynamicArray!(string, 5) toRemove;
            toRemove ~= this._states.byKeyValue.map!(kv => kv.key);
            toRemove.range.each!((key) { this.unregister(key); });
        }

        /++
         + Updates the `Gamestate` that is at the top of the state stack.
         +
         + Notes:
         +  If there are no game states on the stack, then this function does nothing.
         +
         + Params:
         +  delta = The amount of time, in seconds, the last frame took.
         + ++/
        void onUpdate(double delta)
        {
            auto state = this.topMostState;
            if(state !is null)
                state.onUpdate(delta);
        }

        /++
         + Registers a game state.
         +
         + Assertions:
         +  `state` must not be `null`.
         +
         + Notes:
         +  $(P This function will ensure that `state` is initialised.)
         +  $(P `state $(B must) be allocated with `theAllocator`.)
         +  $(P The manager is now in control of the `state`, so no external code should uninitialise or deallocate it.)
         +  $(P If a state called `name` already exists, then it is overwritten.)
         +
         + Params:
         +  name  = The name to associate with `state`. This can later be used with `get`, `push`, and `swap`.
         +  state = The `Gamestate` to register.
         + ++/
        void register(string name, Gamestate state)
        {
            assert(state !is null, "Attempted to register a null game state.");

            if(!state.hasInit)
                state.onInit(this);

            this._states[name] = state;
        }

        /++
         + Unregisters a registered `Gamestate`.
         +
         + Notes:
         +  $(P This function will uninitialise, and deallocate the game state.)
         +  $(P If no state called `name` exists, this function does nothing.)
         + ++/
        void unregister(string name)
        {
            tracef("[Attempting to unregister gamestate '%s']", name);

            auto pointer = (name in this._states);
            if(pointer !is null)
            {
                tracef("[Gamestate '%s' exists, unintiialising...]", name);
                auto state = *pointer;
                state.onUninit();
                theAllocator.dispose(state);

                this._states.remove(name);
            }
        }

        /++
         + Pushes a gamestate to the top of the state stack.
         +
         + Description:
         +  The game state at the top of the state stack is the "active" gamestate.
         +  The active gamestate is the one that will be updated everytime the manager is updated.
         +
         + Exceptions:
         +  `GamestateNotFoundException` if no game state called `name` is found.
         +
         + Params:
         +  name = The name of the `Gamestate` to push.
         + ++/
        @trusted
        void push(string name)
        {
            this._stack ~= this.get(name);
        }

        /++
         + Pops a `Gamestate` from the top of the state stack.
         +
         + Description:
         +  When a gamestate is popped off the stack, then the gamestate under it will become
         +  the top-most game state, and therefore the "active" gamestate.
         +
         + Exceptions:
         +  `GamestateException` if the stack is empty.
         + ++/
        @trusted
        void pop()
        {
            import std.exception : enforce;
            enforce(this._stack.length > 0, new GamestateException("Attempted to pop the game state stack while it is empty."));

            this._stack.length = this._stack.length - 1;
        }

        /++
         + Swaps the top-most `Gamestate` for another game state.
         +
         + Description:
         +  This function is simply a convinience function to pop the current game state, and then
         +  push another one, effetively swapping the top-most state.
         +
         +  If the stack is empty, then the game state will simply be pushed. No popping is done.
         +
         + Exceptions:
         +  See `push` and `pop`.
         +
         + Params:
         +  name = The name of the `Gamestate` to push.
         + ++/
        @trusted
        void swap(string name)
        {
            if(this._stack.length > 0)
                this.pop;
            this.push(name);
        }

        /++
         + Gets a game state.
         +
         + Exceptions:
         +  $(P `GamestateException` if the game state could not be casted to `GS`.)
         +  $(P `GamestateNotFoundException` if there is no game state called `name`.)
         +
         + Params:
         +  GS = The type to cast the game state to.
         +       Use the base `Gamestate` class if no specific class is needed.
         +
         + Returns:
         +  The `Gamestate` called `name` casted to `GS`.
         + ++/
        @trusted
        GS get(GS : Gamestate = Gamestate)(string name) //const
        out(output)
        {
            assert(output !is null, "The function should have thrown an exception...");
        }
        body
        {
            import std.format;
            tracef("[Getting gamestate '%s' as '%s'.]", name, GS.stringof);

            import std.exception : enforce;
            enforce(this._states.hasKey(name), new GamestateNotFoundException(name));

            auto state = cast(GS)this._states[name];
            enforce(state !is null, new GamestateException(format("Unable to cast gamestate '%s' to '%s'.", name, GS.stringof)));

            return state;
        }

        /++
         + Determines if a game state with a certain name is registered.
         +
         + Params:
         +  name = The name of the `Gamestate` to check for.
         +
         + Returns:
         +  `true` if there is a game state called `name`.
         +  `false` otherwise.
         + ++/
        @safe @nogc
        bool isRegistered(string name) nothrow //const
        {
            return this._states.hasKey(name);
        }

        /++
         + Returns:
         +  `null` if the game state stack is empty.
         +  The game state at the top of the game state stack.
         + ++/
        @property @trusted @nogc
        Gamestate topMostState() nothrow //const
        {
            return (this._stack.length == 0) ? null : this._stack[$ - 1];
        }

        /++
         + Returns:
         +  Whether the manager is initialised or not.
         + ++/
        @property @safe @nogc
        bool hasInit() nothrow const
        {
            return this._engine !is null;
        }

        /++
         + Returns:
         +  The `Engine` being used.
         + ++/
        @property @safe @nogc
        inout(Engine) engine() nothrow inout
        out(output)
        {
            assert(output !is null, "The Engine is null.");
        }
        body
        {
            return this._engine;
        }
    }
}
///
unittest
{
    import std.exception : assertThrown, assertNotThrown;
    enum A_DELTA = 200;
    enum B_DELTA = 400;

    class A : Gamestate
    {
        override void onInit(GamestateManager manager)
        {
            super.onInit(manager);
        }

        override void onUninit()
        {
            super.onUninit();
        }

        override void onUpdate(double delta)
        {
            assert(delta == A_DELTA);
            assert(this.manager !is null);
        }
    }

    class B : Gamestate
    {
        override void onInit(GamestateManager manager)
        {
            super.onInit(manager);
        }
        
        override void onUninit()
        {
            super.onUninit();
        }
        
        override void onUpdate(double delta)
        {
            assert(delta == B_DELTA);
            assert(this.manager !is null);
        }
    }

    auto manager = new GamestateManager();
    //manager.onInit(engineObject); // Thankfully it's not required to do this :^). I need to add a special "Engine" object just for testing ~_~

    manager.register("A", new A());
    assert(manager.isRegistered("A"));
    assertNotThrown!GamestateException(manager.get!A("A"));
    assertThrown!GamestateException(manager.get!B("A")); // You can't cast "A" to "B"

    manager.register("B", new B());
    assert(manager.isRegistered("B"));

    assert(manager.topMostState is null);
    manager.push("A");
    assert(manager.topMostState == manager.get("A"));
    manager.push("B");
    assert(manager.topMostState == manager.get("B"));

    manager.onUpdate(B_DELTA);
    manager.pop;
    assert(manager.topMostState == manager.get("A"));
    manager.onUpdate(A_DELTA);

    manager.swap("B");
    assert(manager.topMostState == manager.get("B"));
    manager.pop;
    assert(manager.topMostState is null);
}

/++
 + Thrown whenever something goes wrong with using a `Gamestate`.
 + ++/
class GamestateException : Exception
{
    ///
    @nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

/++
 + Thrown whenever a game state was not found.
 + ++/
class GamestateNotFoundException : GamestateException
{
    /++
     + Params:
     +  gameStateName = The name of the game state that was not found.
     +  msg           = Additional information about what went wrong.
     + ++/
    @safe
    this(string gameStateName, string msg = "", string file = __FILE__, size_t line = __LINE__, Throwable next = null) pure nothrow
    {
        import std.format;
        import std.exception : assumeWontThrow;

        string finalMessage = assumeWontThrow(format("Unable to find a gamestate called '%s'. Additional Information: '%s'", gameStateName, msg));
        super(finalMessage, file, line, next);
    }
}
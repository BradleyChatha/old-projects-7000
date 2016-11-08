/++
 + Contains code that can be used to ease the lifetime managements of objects.
 + ++/
module jengine.core.cache;

private
{
    import std.experimental.logger, std.experimental.allocator;
    import std.typecons : BitFlags, Flag, Yes, No;
    import jaster.containers;
    import jengine.core.engine;
}

/++
 + The interface for any class that can be cached inside the `Cache` class.
 + ++/
interface ICacheable
{
}

/++
 + This class has the ability to cache any `ICacheable`.
 + 
 + Description:
 +  The programmer caches something, for example, a `game.grphics.renderer.Texture`.
 +  The programmer then no longer needs the cached item, so `Cache.disposeOf` is called on it.
 +  The cached item is destroyed, memory is freed, and the name given to it can then be reused.
 +
 + Notes:
 +  $(P `ICacheable` classes $(B must only be allocated with `theAllocator`))
 +  $(P If the `ICacheable` also inherits from `jengine.core.engine.IUninitialisable` in some way, then it's `onUninit` function will be called
 +      when it is destroyed.)
 +  $(P When the `Cache` is destroyed, anything that is cached is also destroyed.)
 + ++/
final class Cache : IInitialisable!Engine
{
    /++
     + Contains information about a cached asset.
     + ++/
    struct Asset
    {
        /++
        + Flags about an `Asset`.
        +
        + Notes:
        +  The seemingly strange name of this enum was chosen is because when the enum is used
        +  it's clean to read, `if(asset.flags & Asset.Is.MarkedForDisposal)`
        + ++/
        enum Is : ubyte
        {
            /++
            + This asset is marked for disposal, and will be destroyed when a call to
            + `Cache.cleanup` is made.
            ++/
            MarkedForDispoal = 1 << 0,

            /++
             + This asset inherits from `IUninitilisable` and should be uninitialised.
             + ++/
            Uninitable       = 1 << 1
        }

        /// The name of the asset.
        string      name;

        /// The asset's data.
        ICacheable  data;

        /// The asset's flags.
        BitFlags!Is flags;
    }

    private
    {
        alias Map = HashMap!(string, Asset);
        Engine  _engine;
        Map     _assets;

        void dispose(Asset asset)
        {
            tracef("[Disposing of asset %s. Flags = %b]", asset.name, cast(ubyte)asset.flags);
            if(asset.flags & Asset.Is.Uninitable)
            {
                auto casted = cast(IUninitialisable)asset.data;
                casted.onUninit();
            }
            
            theAllocator.dispose(asset.data);
            this._assets.remove(asset.name);
        }
    }

    public
    {
        /++
         + Called when the class should initialise everything.
         + 
         + Assertions:
         +  `hasInit` should return `false`.
         + 
         + Params:
         +  engine = The `Engine` being used.
         + ++/
        @safe
        void onInit(Engine engine)
        {
            trace("[Creating a cache]");
            assert(engine !is null, "The Engine is null.");
            this._engine = engine;
        }

        /++
         + Unitinialises the cache, destroys all cached objects, and frees their memory using `theAllocator`.
         +
         + Notes:
         +  Any `IUnitialisable` that is cached will have their `onUninit` function called (if it hasn't already).
         + ++/
        void onUninit()
        {
            trace("[Uninitialising a cache]");
            foreach(kv; this._assets.byKeyValue)
                this.disposeOf(kv.key, No.mark);

            this._engine = null;
        }

        /++
         + Caches an object, and associates a name with it.
         +
         + Throws:
         +  `Exception` if an object is already cached with the name of `name`, and the cached object is not `object`.
         + 
         + Assertions:
         +  Neither parameter may be `null`.
         +
         + Notes:
         +  $(P `object` is now "owned" by this cache, so $(B only) this cache is allowed to 
         +      destroy the object and free it's memory.)
         +  $(P If `object` inherits from `jengine.core.engine.IInitilisable!Engine` or `Iinitialisable!()` then the cache
         +      will ensure that it's been initialised.)
         +  $(P If `object` inherits from `jengine.core.engine.IUninitialisable` then the cache will make sure it's
         +      uninitialised when destroyed.
         +
         + Params:
         +  name   = The name to associate with the object, this can later be used to retrieve it.
         +  object = The `ICacheable` to cache.
         +
         + Returns:
         +  `object`, so code such as `auto texture = cache.cache(Texture.fromFile(...));` can be used.
         + ++/
        @trusted
        T cache(T : ICacheable)(string name, T object)
        {
            import std.exception : enforce;
            assert(name   !is null, "The name for the cached object is null.");
            assert(object !is null, "A null object should not be cached. This is an error in the calling code.");

            // See if the asset is cached, and if it is make sure it's `object`.
            tracef("[Caching asset '%s']", name);
            auto cached = (name in this._assets);
            enforce(cached is null || cached.data == object, "An asset called "~ name ~" is already cached.");

            if(cached !is null)
                return object;

            // Create the Asset to add, and setup it's flags.
            Asset asset;
            asset.name = name;
            asset.data = object;

            if((cast(IUninitialisable)object) !is null)
                asset.flags |= Asset.Is.Uninitable;

            // Initialise `object` if it inherits from one IInitialisables we know about.
            auto initE = cast(IInitialisable!Engine)object;
            if(initE !is null && !initE.hasInit)
                initE.onInit(this._engine);
            else
            {
                auto init = cast(IInitialisable!())object;
                if(init !is null && !init.hasInit)
                    init.onInit();
            }

            this._assets[name] = asset;
            return object;
        }
        // Dummy instansiation
        version(unittest)
        {
            import jengine.graphics.renderer : Texture;
            alias cacheT = cache!Texture;
        }

        /++
         + Cleans up the cache by destroying any asset that is marked for disposal.
         +
         + Notes:
         +  Any `IUninitialisable` will have their `onUninit` called if it hasn't already.
         + ++/
        void cleanup()
        {
            import std.algorithm : filter, each;
            tracef("[Cleaining up any ICacheables marked for disposal]");

            DynamicArray!Asset toDispose;
            this._assets.byKeyValue.filter!(kv => kv.value.flags & Asset.Is.MarkedForDispoal)
                                   .each!(kv => toDispose ~= kv.value);

            toDispose.range.each!(a => this.dispose(a));
        }

        /++
         + Disposes of a cached object.
         +
         + Notes:
         +  $(P `theAllocator` is used to free the object's memory.)
         +  $(P If the object inherits from `IUninitialisable` then it's onUninit function is called.)
         +  $(P If no object called `name` is found, then a warning is logged.)
         +
         + Params:
         +  name = The name of the object to dispose of.
         +  mark = If `Yes.mark` then the object is only marked for disposal (see `Cache.cleanup`)
         +         If `No.mark` then the object will be disposed of immediately.
         + ++/
        void disposeOf(string name, Flag!"mark" mark = No.mark)
        {
            tracef("[Disposing of ICacheable '%s'. MarkingForDisposal = %s]", name, mark);

            auto cached = (name in this._assets);
            if(cached is null)
            {
                warningf("[Attempted to dispose of non-existant ICacheable '%s']", name);
                return;
            }

            if(mark)
                cached.flags |= Asset.Is.MarkedForDispoal;
            else
                this.dispose(*cached);
        }

        /++
         + Retrieves an object from the cache.
         +
         + Throws:
         +  `Exception` if the object cannot be casted to a `T` (or if `name` doesn't exist).
         +
         + Assertions:
         +  `name` must not be null.
         +
         + Params:
         +  name = The name of the object to get.
         +
         + Returns:
         +  The object casted to `T`.
         + ++/
        T get(T : ICacheable = ICacheable)(string name)
        {
            import std.exception : enforce;
            assert(name !is null, "Cannot get an object when the name given is null.");

            auto asset = (name in this._assets);
            enforce(asset !is null, "No asset called " ~ name ~ " was found.");

            auto toReturn = cast(T)asset.data;
            enforce(toReturn !is null, "Could not cast asset '" ~ name ~ "' to type " ~ T.stringof);

            return toReturn;
        }

        /++
         + Determines if an object with a certain name is cached.
         +
         + Notes:
         +  $(P If `name` is `null`, then a warning is logged.)
         +
         + Params:
         +  name = The name to look for.
         +
         + Returns:
         +  `true` if a cached object is called `name`.
         +  `false` otherwise (of if `name` is `null`).
         + ++/
        @trusted
        bool isCached(string name)
        {
            warning(name is null, "[Attempted to use a null name]");
            return this._assets.hasKey(name);
        }
        
        /++
         + Returns:
         +  Whether the class has initialised or not.
         + ++/
        @property @safe @nogc
        bool hasInit() nothrow const
        {
            return (this._engine !is null);
        }
    }
}
///
unittest
{
    import std.exception : assertThrown;

    class C : ICacheable, IInitialisable!()
    {
        bool initted;
        void onInit()   {initted = true;}
        void onUninit() {initted = false;}
        bool hasInit()  {return initted;}
    }

    // TODO: Once Engine is finally implemented fix this unitest to use it.
    auto cache = new Cache(); // Thankfully, "onInit" currently isn't a requirement.
                              // However, we can't actually use onUninit due to a contract failing because of onInit not being called.
    cache.cache("A", new C());
    cache.cache("B", new C());

    assert(cache._assets["A"].flags & Cache.Asset.Is.Uninitable);

    assert(cache.isCached("A"));
    assert(cache.isCached("B"));

    assert(cache.get!C("A").hasInit);

    class B : ICacheable {}
    assertThrown!Exception(cache.get("This name doesn't exist!"));
    assertThrown!Exception(cache.get!B("A")); // Invalid cast

    cache.disposeOf("A", No.mark);
    cache.disposeOf("B", Yes.mark);

    assert(!cache.isCached("A"));
    assert( cache.isCached("B"));
    assert(cache._assets["B"].flags & Cache.Asset.Is.MarkedForDispoal);

    cache.cleanup();
    assert(!cache.isCached("B"));
}
/++
 + Contains code to aid with Maths.
 +
 + $(I Note that the library "gl3n" is used for all of the mathy stuff, so please refer to it's documentation
 +     for anything in that regards.)
 + ++/
module jengine.core.maths;

private
{
    import std.traits  : isNumeric;
    import gl3n.linalg : Vector;
    import gl3n.util   : is_vector;
    import sfml;
}

///
alias Vector2f = Vector!(float, 2);

///
alias Vector2i = Vector!(int,   2);

///
alias Vector2u = Vector!(uint,  2);

///
alias Vector3f = Vector!(float, 3);

///
alias isVector = is_vector; // I don't like the style of "is_vector"

/++
 + A type describing a rectangle.
 +
 + Params:
 +  T           = The numeric type that this rectangle stores.
 +  NativeType  = The native version of the rectangle, aka the type used by the underlying C library.
 ++/
struct Rectangle(T, NativeType)
if(isNumeric!T && (is(NativeType == sfIntRect) || is(NativeType == sfFloatRect)))
{
    /// The vector type being used for this rectangle.
    alias VectorT = Vector!(T, 2);

    public
    {
        /// The rectangle's position.
        VectorT position;

        /// The rectangle's size.
        VectorT size;

        /// An empty (all 0) version of the rectangle.
        enum empty = typeof(this)(0, 0, 0, 0);

        ///
        @safe @nogc
        this(T x, T y, T width, T height) pure nothrow
        {
            this.position = VectorT(x, y);
            this.size     = VectorT(width, height);
        }

        ///
        @safe @nogc
        this(VectorT position, VectorT size) pure nothrow
        {
            this.position = position;
            this.size     = size;
        }

        /++
         + Determines if this rectangle and another rectangle intersect at some point.
         + 
         + Limitations:
         +  Due to laziness, currently `other` must be the same type as this rectangle,
         +  in the future I will allow any different types of `Rectangle` to be used together.
         + 
         + Params:
         +  other = The other `Rectangle` to check for an intersection with.
         + 
         + Returns:
         +  `true` if this rectangle and `other` intersect eachother.
         +  `false` otherwise.
         + ++/
        @trusted @nogc
        bool intersects(const typeof(this) other) nothrow const
        {
            auto rect1 = this.asNative;
            auto rect2 = other.asNative;

            static if(is(NativeType == sfFloatRect))
                return sfFloatRect_intersects(&rect1, &rect2, null) == sfTrue;
            else
                return sfIntRect_intersects(&rect1, &rect2, null) == sfTrue;
        }
        ///
        unittest
        {
            try
            {
                loadSFML();
            }
            catch(Exception)
            {
                import std.experimental.logger;
                warning("[Cannot run test for Rectangle.intersects, as SFML could not be loaded.]");
                return;
            }

            alias This = typeof(this);
            enum rect1 = This(0,  0,  40, 40);
            enum rect2 = This(20, 0,  60, 60);
            enum rect3 = This(60, 60, -3, -3);

            // Can't be static assert for now, not until
            // I bother to implement "Seperating Axis Theorem", so we don't need SFML for it.
            assert( rect1.intersects(rect2));
            assert(!rect1.intersects(rect3));
            assert( rect2.intersects(rect3));
        }

        /++
         + Determines if this rectangle contains a certain point.
         + 
         + Limitations:
         +  Due to laziness, currently `point` must be the same type as `Rectange.VectorT`.
         +  In the future I will allow any type of `Vector!(???, 2)` to be used.
         + 
         + Params:
         +  point = The point to check for inside this rectangle.
         + 
         + Returns:
         +  `true` if this rectangle contains `point`.
         +  `false` otherwise.
         + ++/
        @trusted @nogc
        bool hasPoint(VectorT point) nothrow const
        {
            auto rect = this.asNative;
            static if(is(NativeType == sfFloatRect))
                return sfFloatRect_contains(&rect, point.x, point.y) == sfTrue;
            else
                return sfIntRect_contains(&rect, point.x, point.y) == sfTrue;
        }
        ///
        unittest
        {
            try
            {
                loadSFML();
            }
            catch(Exception)
            {
                import std.experimental.logger;
                warning("[Cannot run test for Rectangle.contains, as SFML could not be loaded.]");
                return;
            }
            
            alias This = typeof(this);
            alias Vect = This.VectorT;
            enum rect  = This(0, 0, 100, 100);

            assert( rect.hasPoint(Vect(0,  0)));
            assert( rect.hasPoint(Vect(50, 50)));
            assert(!rect.hasPoint(Vect(-1, -1)));
        }

        /++
         + Converts a `NativeType` to the rectangle.
         +
         + Params:
         +  rect = The `NativeType` to convert from.
         +
         + Returns:
         +  `rect` as a `Rectangle`.
         ++/
        @property @safe @nogc
        static typeof(this) fromNative(NativeType rect) nothrow pure
        {
            alias Type = typeof(this);
            return Type(VectorT(rect.left, rect.top), VectorT(rect.width, rect.height));
        }
        ///
        unittest
        {
            alias This = typeof(this);
            enum rect  = NativeType(20, 30, 40, 50);
            static assert(This.fromNative(rect) == This(20, 30, 40, 50));
        }

        /++
         + Converts the rectangle into `NativeType`, useful for interacting with the underlying C library.
         +
         + Returns:
         +  The rectangle in as a `NativeType`.
         ++/
        @property @safe @nogc
        NativeType asNative() nothrow pure const
        {
            return NativeType(this.position.x, this.position.y, this.size.x, this.size.y);
        }
        ///
        unittest
        {
            alias This = typeof(this);
            static assert(This(20, 30, 40, 50).asNative == NativeType(20, 30, 40, 50));
        }
    }
}

///
alias FloatRect = Rectangle!(float, sfFloatRect);

///
alias IntRect = Rectangle!(int, sfIntRect);

private void _isRectangle(T, N)(Rectangle!(T, N)){}

/++
 + Determines if a type is an instansiation of `Rectangle`.
 + 
 + Params:
 +  T = The type to check.
 + 
 + Returns:
 +  `true` if `T` is an instantiation of `Rectangle`.
 +  `false` otherwise.
 + ++/
enum isRectangle(T) = is(typeof({_isRectangle(T.init);}));
///
unittest
{
    static assert( isRectangle!FloatRect);
    static assert( isRectangle!IntRect);
    static assert(!isRectangle!int);
}

/++
 + Converts a vector from one type to another.
 + 
 + Params:
 +  T    = The numeric type to convert to.
 +  vect = The `Vector` to convert.
 + 
 + Returns:
 +  `Vect` as a `Vector!(T, 2)`.
 + ++/
Vector!(T, 2) asVector2(T, Vect)(const Vect vect)
if(isVector!Vect && Vect.dimension == 2)
{
    return typeof(return)(cast(T)vect.x, cast(T)vect.y);
}
///
unittest
{
    static assert(Vector2f(32, 64).asVector2!int == Vector2i(32, 64));
}

/++
 + Like `asVector2` but converts `vect` into it's native version.
 + This function is intended for internal use only, hence the lacking documentation.
 + ++/
public auto asNativeVector2(T, Vect)(Vect vect)
if(isVector!Vect && Vect.dimension == 2)
{
    static if(is(T == float))       alias V = sfVector2f;
    else static if(is(T == int))    alias V = sfVector2i;
    else static if(is(T == uint))   alias V = sfVector2u;
    else static assert(false, "No Native version for " ~ T.stringof);

    return V(cast(T)vect.x, cast(T)vect.y);
}
///
unittest
{
    static assert(Vector2f(32, 64).asNativeVector2!float == sfVector2f(32, 64));
}
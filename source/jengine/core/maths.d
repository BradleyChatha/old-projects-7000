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

/++
 + A type describing a rectangle.
 +
 + Params:
 +  T        = The numeric type that this rectangle stores.
 +  SfmlType = The SFML version of the rectangle.
 ++/
struct Rectangle(T, SfmlType)
if(isNumeric!T && (is(SfmlType == sfIntRect) || is(SfmlType == sfFloatRect)))
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
         + Converts an `SfmlType` to the rectangle.
         +
         + Params:
         +  sfml = The `SfmlType` to convert from.
         +
         + Returns:
         +  `sfml` as a `Rectangle`.
         ++/
        @property @safe @nogc
        static typeof(this) fromSfml(SfmlType sfml) nothrow pure
        {
            alias Type = typeof(this);
            return Type(VectorT(sfml.left, sfml.top), VectorT(sfml.width, sfml.height));
        }
        ///
        unittest
        {
            alias This = typeof(this);
            enum rect  = SfmlType(20, 30, 40, 50);
            static assert(This.fromSfml(rect) == This(20, 30, 40, 50));
        }

        /++
         + Converts the rectangle into `SfmlType`, useful for interacting with SFML.
         +
         + Returns:
         +  The rectangle in as a `SfmlType`.
         ++/
        @property @safe @nogc
        SfmlType asSfml() nothrow pure const
        {
            return SfmlType(this.position.x, this.position.y, this.size.x, this.size.y);
        }
        ///
        unittest
        {
            alias This = typeof(this);
            static assert(This(20, 30, 40, 50).asSfml == SfmlType(20, 30, 40, 50));
        }
    }
}

///
alias FloatRect = Rectangle!(float, sfFloatRect);

///
alias IntRect = Rectangle!(int, sfIntRect);
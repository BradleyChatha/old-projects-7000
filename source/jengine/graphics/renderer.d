/++
 + Contains code for rendering basic stuff to the screen.
 + ++/
module jengine.graphics.renderer;

private
{
    import std.experimental.allocator.mallocator, std.experimental.logger, std.experimental.allocator;
    import std.exception : enforce;

    import jengine.core.engine;
    import jengine.core.maths;
    import jengine.core.cache;
    import jengine.graphics.window;
    import jengine.thirdparty;

    import jaster.smartptr;
    import gl3n.linalg : Vector;
}

/// Note that because gl3n's `Vector` is buggy (or rather, D is) it will store a `uint` instead of a `ubyte`
/// The `checkColour` function is provided to make sure all of the values are within 0-255, and fails an assert otherwise.
alias Colour = Vector!(uint, 4);

/++
 + Checks a `Colour` to make sure it's values are between 0-255.
 +
 + Notes:
 +  This function makes use of `assert`s, so there is no overhead for using it in release builds.
 + 
 + Assertions:
 +  The `r`, `g`, `b`, and `a` values of `colour` must be between 0-255 (inclusive)
 +
 + Params:
 +  colour = The colour to check.
 + ++/
@safe @nogc
void checkColour(const Colour colour) nothrow pure
{
    assert(colour.r >= 0 && colour.r <= 255, "The Red value is out of bounds.");
    assert(colour.g >= 0 && colour.g <= 255, "The Blue value is out of bounds.");
    assert(colour.b >= 0 && colour.b <= 255, "The Green value is out of bounds.");
    assert(colour.a >= 0 && colour.a <= 255, "The Alpha value is out of bounds.");
}
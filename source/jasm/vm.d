module jasm.vm;

private
{
    import jasm.opcodes;
}

/++
 + Describes a variable.
 + ++/
struct Variable
{
    /++
     + The different types of a variable.
     + ++/
    public enum Type : ushort
    {
        // Type(First byte)
        String              = 0x0001,

        Int32               = 0x0002,
        UInt32              = Int32 | Unsigned,

        // Flags(Second byte)
        Unsigned            = 0x0100 << 0
    }

    /++
     + This union is used to store the value of the variable.
     + ++/
    package union Payload
    {
        string  str;
        int     i32;
        uint    ui32;
    }

    private
    {
        Type    _type;
        Payload _value;

        @safe @nogc 
        this(Type type) nothrow pure
        {
            this._type = type;
        }
    }

    public
    {
        /++
         + Params:
         +  value = The value of the variable.
         + ++/
        this(T)(T value)
        {
            this = Variable.make(value);
        }

        /++
         + A convinience function for being able to specify the value's type.
         + 
         + This is useful in cases such as `Variable.make!uint(60)`, where normally, `T` would end up being an `int`
         + 
         + Assertions:
         +  `T` must have a corresponding `Variable.Type`
         + 
         + Params:
         +  value = The value of the variable.
         + 
         + Returns:
         +  A `Variable` with `value` as it's value.
         + ++/
        static Variable make(T)(T value)
        {
            alias type = VarTypeOf!T;
            auto  var  = Variable(type);

            static if(type == Type.Int32)
                var._value.i32 = value;
            else static if(type == Type.UInt32)
                var._value.ui32 = value;
            else static if(type == Type.String)
                var._value.str = value;
            else
                static assert(false, "[BUG] VarTypeOf should've 'assert(false)'ed");

            return var;
        }
        ///
        @safe
        unittest
        {
            auto var = Variable.make!uint(60);  // uint
            var      = Variable.make(60);       // int
            var      = Variable.make("Soupy");  // string
        }

        /++
         + Returns:
         +  The variable's `Type`.
         + ++/
        @property @safe @nogc
        Type type() pure nothrow const
        {
            return this._type;
        }
        ///
        @safe
        unittest
        {
            static assert(Variable.make!uint(60).type == Type.UInt32);
            static assert(Variable(60).type           == Type.Int32);
            static assert(Variable("Soupy").type      == Type.String);
        }

        /++
         + Gets the value of the variable.
         + 
         + If `strict` is `true`, then an exception is thrown if `T` is not the same type as the variable's value.
         + If `strict` is `false`, however, then an exception is only thrown if `T` is not implicitly convertable to the variable's type.
         +
         + Assertions:
         +  `T` must have a corresponding `Variable.Type`
         + 
         + Throws:
         +  If `[strict]` is `true` - `VariableTypeException` if the type of `T` does not match the variable's type.
         +  If `[strict]` is `false` - `VariableTypeException` if the type of `T` is not implicitly convertable to the variable's type.
         + 
         + Returns:
         +  The value of the variable, as `T`.
         + ++/
        @property
        inout(T) as(T, bool strict = true)() inout
        {
            T value = this.asRef!(T, strict);
            return value;
        }
        ///
        @safe
        unittest
        {
            import std.exception : assertThrown, assertNotThrown;

            void makeVar(T)(T value)
            {
                alias type = VarTypeOf!T;
                const var  = Variable.make!T(value);

                assert(var.type == type);
                assert(var.as!T == value);
            }

            makeVar!uint(60);
            makeVar(60);
            makeVar("Soupy Daniel");

            auto var = Variable.make!uint(60);
            assertThrown(var.as!int);               // It defaults to being strict, and "uint" and "int" result in different `Variable.Type`s
            assertNotThrown(var.as!(int, false));   // Non-strict
        }

        /++
         + Gets a reference to the variable's value.
         + 
         + If `strict` is `true`, then an exception is thrown if `T` is not the same type as the variable's value.
         + If `strict` is `false`, however, then an exception is only thrown if `T` is not implicitly convertable to the variable's type.
         +
         + Assertions:
         +  `T` must have a corresponding `Variable.Type`
         + 
         + Throws:
         +  If `[strict]` is `true` - `VariableTypeException` if the type of `T` does not match the variable's type.
         +  If `[strict]` is `false` - `VariableTypeException` if the type of `T` is not implicitly convertable to the variable's type.
         + 
         + Returns:
         +  A reference to the variable's value.
         + ++/
        @property
        ref inout(T) asRef(T, bool strict = true)() inout
        {
            import std.exception : enforce;
            
            alias type = VarTypeOf!T;

            static if(strict)
                enforce(this.type == type, new VariableTypeException(type, this.type));
            else
                enforce(this.type.canConvert(type), new VariableTypeException(type, this.type));
            
            static if(type == Type.Int32)
                return this._value.i32;
            else static if(type == Type.UInt32)
                return this._value.ui32;
            else static if(type == Type.String)
                return this._value.str;
            else
                static assert(false, "[BUG] No code to handle type: " ~ T.stringof);
        }
        ///
        @safe
        unittest
        {
            auto var = Variable.make!uint(200);
            var.asRef!uint *= 5;

            assert(var.as!uint == 1000);
        }
    }
}

/++
 + The base exception for any exception thrown by the VM.
 + ++/
class VMException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

/++
 + The base exception for any exception thrown that's related to variables.
 + ++/
class VariableException : VMException
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

/++
 + This exception is thrown whenever the type to convert to is not the same or compatible with the `Variable`'s type.
 + ++/
class VariableTypeException : VariableException
{
    public
    {
        /// The type recieved.
        Variable.Type got;

        /// The type expected.
        Variable.Type expected;
    }

    /++
     + Params:
     +  got         = The `Variable.Type` that was recieved.
     +  expected    = The 'Variable.Type' that was expected.
     + ++/
    @safe
    this(Variable.Type got, Variable.Type expected, string file = __FILE__, size_t line = __LINE__, Throwable next = null) pure nothrow
    {
        import std.format       : format;
        import std.exception    : assumeWontThrow;

        this.got        = got;
        this.expected   = expected;
        super(assumeWontThrow(format("Type mismatch, '%s' is not compatible with '%s' in this context..", got, expected)), file, line, next);
    }
}

/++
 + Determines if `from` can convert into `to`.
 + 
 + Params:
 +  from = The type to convert from.
 +  to   = The type to convert to.
 + 
 + Returns:
 +  `true` if `from` can convert into `to`.
 +  `false` otherwise.
 + ++/
@safe @nogc
bool canConvert(Variable.Type from, Variable.Type to) pure nothrow
{
    enum _T
    {
        String,
        Integer
    }

    @safe @nogc
    _T findT(Variable.Type type) pure nothrow
    {
        switch(type) with(Variable.Type)
        {
            case String:
                return _T.String;

            case Int32:
            case UInt32:
                return _T.Integer;

            default:
                assert(false);
        }
    }

    auto fromT = findT(from);
    auto toT   = findT(to);

    return (fromT == toT);
}
///
unittest
{
    with(Variable.Type)
    {
        static assert( canConvert(Int32,     UInt32));
        static assert( canConvert(String,    String));
        static assert(!canConvert(String,    UInt32));
    }
}

/++
 + Determines the appropriate `Variable.Type` for `T`.
 + 
 + Params:
 +  [T] = The type to find the `Variable.Type` for.
 + 
 + Returns:
 +  The `Variable.Type` that represents `[T]`.
 + ++/
template VarTypeOf(T)
{
    static if(is(T == string))
        alias VarTypeOf = Variable.Type.String;
    else static if(is(T == int))
        alias VarTypeOf = Variable.Type.Int32;
    else static if(is(T == uint))
        alias VarTypeOf = Variable.Type.UInt32;
    else
        static assert(false, "There is no Jasm variable type for: " ~ T.stringof);
}
///
unittest
{
    static assert(VarTypeOf!string     == Variable.Type.String);
    static assert(VarTypeOf!int        == Variable.Type.Int32);
    static assert(VarTypeOf!uint       == Variable.Type.UInt32);
}
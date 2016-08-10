module jasm.reader;

version(none):
private
{
    import std.format       : format;
    import std.traits       : isNumeric, Unqual;
    import std.exception    : enforce;
    import std.range        : isInputRange, ElementType;

    debug import std.stdio  : writefln;

    import jasm.opcodes, jasm.compiler;
}

/++
 + Describes a Jasm namespace inside of a JExe
 + ++/
struct JExeNamespace
{
    /// The name of the namespace, namespaces are not broken up. So "Jasm/IO" might be it's name.
    string      name;

    /// The classes that belong to this namespace.
    JExeClass[] classes;
}

/++
 + Describes a Jasm class inside of a JExe
 + ++/
struct JExeClass
{
    /// The name of the class.
    string          name;

    /// The functions that belong to this class.
    JExeFunction[]  functions;

    /// The class' flags.
    ubyte           flags;
}

/++
 + Describes a Jasm function inside of a JExe.
 + ++/
struct JExeFunction
{
    /// The name of the function.
    string      name;

    /// The function's parameter types.
    string[]    paramTypes;

    /// The function's local variables types.
    string[]    localTypes;

    /// The funciton's return type.
    string      retType;

    /// The function's flags.
    FuncFlags   flags;

    /// The data making up the function.
    ubyte[]     data;

    // Don't need to worry about these.
    uint        pointer;
    uint        size;
}

private void _isJExeReader(R)(JExeReader!R) {}

/++
 + Determines if $(B R) is a `JExeReader`.
 + ++/
template isJExeReader(R) 
{
    enum isJExeReader = is(typeof(_isJExeReader(R.init)));
}
///
unittest
{
    assert(isJExeReader!(JExeReader!(ubyte[])));
    assert(!isJExeReader!int);
}

/++
 + 
 + ++/
struct JExeReader(R)
if(isInputRange!R && is(Unqual!(ElementType!R) == ubyte))
{
    private
    {
        ushort  _fileVersion;
        ubyte   _flags;
        R       _range;
        ubyte[] _instructions;

        JExeNamespace[] _namespaces;
        string[]        _stringTable;

        /++
         + Reads a certain amount of bytes from the input range.
         + ++/
        ubyte[] readBytes(size_t amount)
        {
            ubyte[] buffer;
            buffer.length = amount;

            foreach(i; 0..amount)
            {
                enforce(!this._range.empty, 
                    new JExeException(format("Unable to read data of size %s(0x%X): Unexpected end of data", amount, amount)));
                
                buffer[i] = this._range.front;
                this._range.popFront;
            }

            return buffer;
        }

        /++
         + Reads a number from the range.
         + ++/
        T read(T)()
        if(isNumeric!T)
        {
            ubyte[T.sizeof] buffer;

            foreach(i; 0..buffer.length)
            {
                buffer[i] = this._range.front;
                this._range.popFront;
            }

            return (cast(T[])(cast(void[])buffer))[0];
        }
        ///
        unittest
        {
            uint    num    = 0xDEADBEEF;
            ubyte[] bytes  = cast(ubyte[])(cast(void[])((&num)[0..1]));
            auto    exe    = JExeReader(bytes, false);

            assert(exe.read!uint == num);
        }

        /++
         + Reads a string from the data.
         + 
         + Params:
         +  T = What type of prefix the string has.
         + ++/
        string readString(T)()
        if(isNumeric!T)
        {
            import std.exception : assumeUnique;

            auto size       = this.read!T;
            ubyte[] buffer  = this.readBytes(size);

            return (cast(char[])buffer).assumeUnique;
        }
        ///
        unittest
        {
            import std.exception : assertThrown;
            import std.array;

            ushort  length = 0x0004;
            ubyte[] bytes  = cast(ubyte[])(cast(void[])((&length)[0..1]));
            bytes         ~= ['S', 'o', 'u', 'p'];

            assert(JExeReader(bytes, false).readString16 == "Soup");

            bytes[0] = 0xFF;
            assertThrown!JExeException(JExeReader(bytes, false).readString8);
        }

        alias readString8  = readString!ubyte;
        alias readString16 = readString!ushort;
        alias readString32 = readString!uint;

        /// Constructor for unittests
        this(R range, bool bleb)
        {
            this._range = range;
        }
    }

    public
    {
        /++
         + Creates a reader around the given input range.
         + 
         + Params:
         +  range = The input range of ubytes that contains all of the data for a JEXE.
         + ++/
        this(R range)
        {
            this._range = range;
            this.validateHeader();
            this.readFile();
        }

        /++
         + Returns the information about all the namespaces in the JExe
         + ++/
        @property @safe @nogc
        JExeNamespace[] namespaces() nothrow pure
        {
            return this._namespaces;
        }

        /++
         + Returns the string table found in the JExe
         + ++/
        @property @safe @nogc
        string[] stringTable() nothrow pure
        {
            return this._stringTable;
        }

        /++
         + Returns the instructions in the JExe.
         + ++/
        @property @safe @nogc
        ubyte[] instructions() nothrow pure
        {
            return this._instructions;
        }
    }

    private
    {
        void readFile()
        {
            auto namespaces = this.readNamespaces();

            // Read in the opcodes
            auto amount         = this.read!uint;
            this._instructions  = this.readBytes(amount);

            // Now go over every function, and find their data.
            foreach(ref namespace; namespaces)
            {
                foreach(ref cls; namespace.classes)
                {
                    foreach(ref func; cls.functions)
                    {
                        enforce(func.pointer + func.size <= this._instructions.length, 
                            new JExeException(format("For function '%s', it's pointer and size are invalid.", func)));
                            
                        func.data = this._instructions[func.pointer..func.pointer + func.size];
                    }
                }
            }

            this._namespaces = namespaces;
            this.readStrings();
        }

        /++
         + Reads in the string table.
         + ++/
        void readStrings()
        {
            auto length = this.read!uint;
            this._stringTable.reserve(length);

            debug writefln("Reading in %s strings from the string table.", length);

            foreach(i; 0..length)
                this._stringTable ~= this.readString16;
        }

        /++
         + Confirms that the header is valid.
         + ++/
        void validateHeader()
        {            
            // First, the magic number
            foreach(ch; Compiler.fileHeader)
            {
                enforce(this._range.front == ch, new JExeException("Invalid magic number."));
                this._range.popFront;
            }
            
            this._fileVersion = this.read!ushort;
            this._flags       = this.read!ubyte;

            enforce(Compiler.fileVersion >= this._fileVersion, new JExeException("Unsupported version of JExe"));
        }
        unittest
        {
            version(LittleEndian)
                ubyte[] vers = [0x01, 0x00];
            else
                ubyte[] vers = [0x00, 0x01];
            
            import std.exception : assertThrown, assertNotThrown;
            import std.array;
            
            ubyte[] jexe = ['J', 'E', 'X', 'E'];
            jexe        ~= vers;
            jexe        ~= 0x00;
            
            assertNotThrown!JExeException(JExeReader(jexe, false).validateHeader());
            assertThrown!JExeException(JExeReader([0x00], false).validateHeader());
        }

        /++
         + Reads in all of the namespaces.
         + ++/
        JExeNamespace[] readNamespaces()
        {
            auto amount = this.read!uint;
            //debug writefln("[Debug] Reading in %s(0x%X) namespaces.", amount, amount);

            JExeNamespace[] array;
            foreach(i; 0..amount)
                array ~= this.nextNamespace;

            return array;
        }

        /++
         + Reads in the next namespace.
         + ++/
        JExeNamespace nextNamespace()
        {
            JExeNamespace ns;

            ns.name     = this.readString8;            
            uint amount = this.read!uint;
            //debug writefln("[Debug] For namespace %s, reading in %s classes.", ns, amount);

            foreach(i; 0..amount)
                ns.classes ~= this.nextClass();
            
            return ns;
        }

        /++
         + Reads in the next class.
         + ++/
        JExeClass nextClass()
        {
            JExeClass cls;
            cls.name  = this.readString8;
            cls.flags = cast(FuncFlags)this.read!ubyte;

            uint amount = this.read!uint;
            //debug writefln("[Debug] For class %s, reading in %s functions.", cls, amount);

            foreach(i; 0..amount)
                cls.functions ~= this.nextFunction();

            return cls;
        }

        /++
         + Reads and returns the next JExeFunction in the data.
         + Note that this does not set the `data` field, as that has to be done later on in reading.
         + ++/
        JExeFunction nextFunction()
        {
            import std.algorithm : splitter, filter;
            JExeFunction func;

            // Parse name, param types, and return type
            auto   temp         = this.readString16;
            bool   foundReturn  = false;
            bool   foundName    = false;
            size_t x, y;

            func.name = temp;
            foreach(ch; temp)
            {
                if(ch == '&' || ch == '$')
                {
                    enforce(x - y != 0, new JExeException("Malformed function name(General): " ~ temp));

                    bool skip = false;
                    if(!foundName)
                    {
                        x         = y + 1;
                        skip      = true;
                        foundName = true;
                    }

                    if(ch == '$')
                    {
                        enforce(!foundReturn, new JExeException("The function '"~temp~"' has 2 return values?"));
                        foundReturn = true;
                    }

                    if(!skip)
                    {
                        func.paramTypes ~= temp[x..y];
                        x                = y + 1;
                    }
                }

                y += 1;
            }
            enforce(foundReturn && x - y != 0, new JExeException("Malformed function name(BadReturnType): " ~ temp));
            func.retType = temp[x..y];

            // Parse local variable types.
            auto split = this.readString16().splitter('&');
            foreach(str; split.filter!((s) => s.length > 0)) // Mm, this doesn't do any error checking, so malformed stuff will be accepted...
                func.localTypes ~= str;

            func.flags   = cast(FuncFlags)this.read!ubyte;
            func.pointer = this.read!uint;
            func.size    = this.read!uint;

            return func;
        }
    }
}

version(unittest)
{
    import std.array;
    alias JustComplileForMe = JExeReader!(ubyte[]);
}

/++
 + Thrown by the VM whenever something goes wrong.
 + ++/
class VMException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

/++
 + Thrown whenever an invalid JExe is read in.
 + ++/
class JExeException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}
module jasm.vm;

private
{
    import jasm.ast, jasm.compiler, jasm.lexer, jasm.opcodes, jasm.reader;
}

/++
 + Describes a namespace
 + ++/
struct Namespace
{
    /// The name of the namespace.
    string  name;

    /// The classes that belong to this namespace.
    Class[] classes;
}

/++
 + Describes a class.
 + ++/
struct Class
{
    /// The name of the class.
    string      name;

    /// The namespace this class belongs to.
    Namespace   namespace;

    /// The flags about this class.
    ClassFlags  flags;

    /// The functions that belong to this class.
    Function[]  functions;
}

/++
 + Describes a function.
 + ++/
struct Function
{
    /// The name of the function.
    string          name;

    /// The class this function belongs to.
    Class           parentClass;

    /// The flags of the function.
    FuncFlags       flags;

    /// The pointer to where the function's instructions start.
    const(size_t)   pointer;
}

/++
 + ++/
class JasmVirtualMachine
{
    private
    {
        Memory  _mem;
    }

    public
    {
    }
}

/++
 + Represents the memory of the VM.
 + ++/
struct Memory
{
    private
    {
        /// Contains all of the opcodes.
        ubyte[] _opcodes;
    }

    public
    {
        /++
         + Gets an opcode from a certain index.
         + 
         + Notes:
         +  Currently does not do any bounds checking(Outside of D's built-in one).
         + 
         + Params:
         +  index = The index of the opcode to get.
         + 
         + Returns:
         +  The opcode at $(D index)
         + ++/
        @safe @nogc
        ubyte getOpcode(size_t index) nothrow
        {
            return this._opcodes[index];
        }
        ///
        unittest
        {
            ubyte[] data = [0, 1, 2, 3, 4];
           
            Memory mem;
            mem.addOpcodes(data);

            foreach(i; 0..data.length)
                assert(data[i] == mem.getOpcode(i));
        }

        /++
         + Gets a slice of opcodes.
         + 
         + Params:
         +  x = The start position of the range.
         +  y = The end position of the range. Not-inclusive.
         + 
         + Returns:
         +  A slice of the opcodes to `[x..y]`
         + ++/
        @safe @nogc
        const(ubyte[]) getOpcodes(size_t x, size_t y) nothrow
        {
            return this._opcodes[x..y];
        }
        ///
        unittest
        {
            ubyte[] data = [0, 1, 2, 3];

            Memory mem;
            mem.addOpcodes(data);

            assert(mem.getOpcodes(1, 3) == data[1..3]);
        }

        /++
         + Returns:
         +  A const reference to the opcodes.
         + ++/
        @property @safe @nogc
        const(ubyte[]) opcodes() nothrow
        {
            return this._opcodes;
        }
    }

    package
    {
        /++
         + Adds bytes into the opcode memory.
         + 
         + Params:
         +  opcode = The opcodes to add.
         + ++/
        @safe
        void addOpcodes(const(ubyte)[] opcodes)
        {
            this._opcodes ~= opcodes;
        }
        ///
        unittest
        {
            ubyte[] data = [0, 2, 1, 3, 4, 5, 6, 7];

            Memory mem;
            mem.addOpcodes(data);

            assert(mem._opcodes.length == data.length);
            assert(mem._opcodes        == data);
        }
    }
}
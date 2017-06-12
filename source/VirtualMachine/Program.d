module VirtualMachine.Program;

import std.stdio;
import std.exception;
import std.format : format;
import std.bitmanip;

class ProgramException : Exception
{
    mixin basicExceptionCtors;
}

struct ProgramHeader
{
    char[3] MagicNumber;
    ubyte[] PointerTable;
    ubyte[] FunctionTable;

    uint PointerTableLength = 0;
    uint FunctionTableLength = 0;
}

struct ProgramBody
{
    ubyte[] Body;
}

final class Program
{
    public this(string ProgramPath)
    {
        this.ProgramFile = File(ProgramPath, "rb");

        if(!this.ProgramFile.isOpen())
            throw new ProgramException(format("Failed to find executable '%s'.", ProgramPath));

        for(int i = 0; i < 3; i++)
            this.Header.MagicNumber[i] = cast(char)this.ProgramFile.readBytes(1)[0];

        ///Pointer Table length
        this.Header.PointerTableLength = bigEndianToNative!int(cast(ubyte[4])this.ProgramFile.readBytes(4)[0..4]);
        ///Function Table length.
        this.Header.FunctionTableLength = bigEndianToNative!int(cast(ubyte[4])this.ProgramFile.readBytes(4)[0..4]);

        for(int i = 0; i < this.Header.PointerTableLength; i++)
            this.Header.PointerTable ~= this.ProgramFile.readBytes(1)[0];

        for(int i = 0; i < this.Header.FunctionTableLength; i++)
            this.Header.FunctionTable ~= this.ProgramFile.readBytes(1)[0];

        for(int i = 0; i < (this.ProgramFile.size() - (this.Header.PointerTableLength + this.Header.FunctionTableLength + 3 + (4 * 2))); i++)
            this.Body.Body ~= this.ProgramFile.readBytes(1)[0];

        this.ProgramFile.close();
    }

    public ~this()
    {
    }

    public ProgramHeader Header;
    public ProgramBody Body;

    private File ProgramFile;
}

ubyte[] readBytes(File f, size_t amount)
{
    import std.exception : enforce;

    ubyte[] buffer = new ubyte[amount];
    auto slice     = f.rawRead(buffer);
    
    enforce(slice.length == amount, format("Attempted to read in %s bytes, but could only read in %s bytes. Cursor = 0x%X (%s)", 
                                           amount, slice.length, f.tell(), f.tell()));

    return buffer;
}

unittest
{
    Program Prog = new Program("Test.SVMA");

    assert(Prog.Header.MagicNumber[0] == 'S', "Failed to read in Magic number");
    assert(Prog.Header.MagicNumber[1] == 'V', "Failed to read in Magic number");
    assert(Prog.Header.MagicNumber[2] == 'M', "Failed to read in Magic number");

    //assert(Prog.Header.PointerTableLength == 0x00000001, format("Failed to read Pointer Table Length. %s was read in", Prog.Header.PointerTableLength));
    //assert(Prog.Header.FunctionTableLength == 0x00000001, format("Failed to read Function Table Length. %s was read in", Prog.Header.FunctionTableLength));

    assert(Prog.Header.PointerTable.length == Prog.Header.PointerTableLength, format("Read in the incorrect amount of bytes for the pointer table. %s read in, wanted %s.", Prog.Header.PointerTable.length, Prog.Header.PointerTableLength));
    assert(Prog.Header.FunctionTable.length == Prog.Header.FunctionTableLength, format("Read in the incorrect amount of bytes for the function table. %s read in, wanted %s.", Prog.Header.FunctionTable.length, Prog.Header.FunctionTableLength));

    writeln(format("The program body length is: %s bytes.", Prog.Body.Body.length));
}


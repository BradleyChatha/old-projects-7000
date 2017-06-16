module VirtualMachine.Machine;

import std.exception;
import std.stdio : File, writeln;
import std.format : format;
import std.array : popFront;
import std.bitmanip : bigEndianToNative;

class ProgramException : Exception
{
    mixin basicExceptionCtors;
}

class ProgramComponent
{
    public this(ubyte[] Bytes)
    {
        this.Contents = Bytes;
    }

    /**
     * Gets the next byte in the contents array.
     * Params:
     *      AdvanceCounter: If true the counter gets incremented otherwise it doesn't. Defaults to true.
     **/
    public ubyte GetNextByte(bool AdvanceCounter = true)
    {
        if(this.Counter > this.Length)
            throw new ProgramException("Cannot read past the length of the contents.");

        ubyte Byte = this.Contents[this.Counter];

        if(AdvanceCounter)
            this.Counter += 1;

        return Byte;
    }

    /**
     * Gets the next series of bytes in the contents array.
     * Params:
     *      Length: The length of the data you want to get.
     *      AdvanceCounter: If true the counter gets incremented otherwise it doesn't. Defaults to true.
     **/
    public ubyte[] GetByteArray(uint Length, bool AdvanceCounter = true)
    {
        if(this.Counter > this.Length)
            throw new ProgramException("Cannot read past the length of the contents.");

        ubyte[] Bytes;

        for(int i = this.Counter; i < (this.Counter + Length); i++)
        {
            Bytes ~= this.Contents[i];
        }

        if(AdvanceCounter)
            this.Counter += Length;

        return Bytes;
    }

    /**
     * Peeks at the next byte and returns it, without incrementing the counter.
     * Params:
     *      Offset: How far into the array you want to look. Default is 0.
     **/
    public ubyte PeekByte(uint Offset = 0)
    {
        if(this.Counter > this.Length)
            throw new ProgramException("Cannot read past the length of the contents.");

        return this.Contents[this.Counter + Offset];
    }

    /**
     * Converts the size of T bytes to type T.
     * Params:
     *      AdvanceCounter: If true the counter gets incremented otherwise it doesn't. Defaults to true.
     **/
    T ByteArrayToType(T)(bool AdvanceCounter = true)
    {
        if(this.Counter + T.sizeof > this.Length)
            throw new ProgramException("Cannot read past the length of the contents.");

        T Data = bigEndianToNative!T(cast(ubyte[T.sizeof])this.Contents[this.Counter..this.Counter + T.sizeof][0..T.sizeof]);

        if(AdvanceCounter)
            this.Counter += T.sizeof;

        return Data;
    }

    /**
     * Gets the length of the contents array.
     **/
    @property
    uint Length()
    {
        return cast(uint)this.Contents.length;
    }

    public ubyte[] Contents;
    public uint Counter;
}

final class Program
{
    public this(string Path)
    {
        File App = File(Path, "rb");

        if(!App.isOpen)
            throw new ProgramException(format("Failed to open '%s'", Path));

        ubyte[] Data = new ubyte[cast(uint)App.size];
        App.rawRead(Data);

        if(Data.length == 0)
            throw new ProgramException(format("Failed to read in data from '%s'.", Path));

        ubyte[] MagicNumber = new ubyte[3];
        for(int i = 0; i < 3; i++)
        {
            MagicNumber[i] = Data[0];
            Data.popFront;
        }

        if(MagicNumber != cast(ubyte[])['S', 'V', 'M'])
            throw new ProgramException(format("Unkown magic number '%s'.", MagicNumber));

        ProgramComponent ProgramInitaliserComponent = new ProgramComponent(Data);

        uint PointerTableLength = ProgramInitaliserComponent.ByteArrayToType!(uint)();
        uint FunctionTableLength = ProgramInitaliserComponent.ByteArrayToType!(uint)();
        
        this.PointerTable = new ProgramComponent(ProgramInitaliserComponent.GetByteArray(PointerTableLength));
        this.FunctionTable = new ProgramComponent(ProgramInitaliserComponent.GetByteArray(FunctionTableLength));

        uint Length = ProgramInitaliserComponent.Length - ProgramInitaliserComponent.Counter;

        this.ProgramBody = new ProgramComponent(ProgramInitaliserComponent.GetByteArray(Length));

        App.close();
    }

    public ProgramComponent PointerTable;
    public ProgramComponent FunctionTable;
    public ProgramComponent ProgramBody;
}
unittest
{
    Program Comp = new Program("Test.SVMA");
}
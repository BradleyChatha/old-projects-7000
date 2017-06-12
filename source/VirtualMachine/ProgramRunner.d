module VirtualMachine.ProgramRunner;

import std.stdio;
import std.bitmanip;
import std.format;
import std.exception;
import VirtualMachine.Machine;
import VirtualMachine.Program;

enum ProgramInstructions
{
    ///A void operation is represented as 0x00, it simply means skip this byte.
    VOID = 0,
    ///This flushes bytes to STDOUT, access through C. It'll depend of proceeding bytes.
    ///The next byte *is not* what is pushed to STDOUT, that dictates what is pushed.
    STDOUT,
    ///STDIN Reads from STDIN, access through C. It either goes to a normal variable,
    ///Or an address which points to the pointer table.
    STDIN,
    ///Represents a signed integer value, then the next 4 bytes are read in.
    INTEGER,
    ///Represents a floating point number, 4 bytes are read in.
    FLOAT,
    ///Represents a string literal, next byte shows length (n) then n bytes are read in as the string.
    STRING,
    ///Represents when a variable is being accessed. The next byte is the pointer.
    VARIABLE,
    ///Tells the machine to jump to a location, the next uint is where to jump to.
    JUMP
}

enum ProgramVariableUseage
{
    ///Getting for calcualtions and for outputting, etc...
    Access = 0,
    ///Assigning the variable some data, either over writing or initalising. 
    Assignment
}

class ProgramRunnerException : Exception
{
    mixin basicExceptionCtors;
}

void RunProgram(Machine Mach)
{
    Program Prog = Mach.Prog;

    while(Mach.ProgramCounter < Prog.Body.Body.length)
    {
        ProgramInstructions CurrentInstruction = cast(ProgramInstructions)Prog.Body.Body[Mach.ProgramCounter];
        Mach.ProgramCounter += 1;

        if(CurrentInstruction == ProgramInstructions.VOID)
            continue;
        else if(CurrentInstruction == ProgramInstructions.JUMP)
        {
            uint Location = bigEndianToNative!int(cast(ubyte[4])Mach.ReadBytes(4)[0..4]);
            Mach.ProgramCounter = Location;
        }
        else if(CurrentInstruction == ProgramInstructions.STDOUT)
        {
            RawValueToStdout(Mach);
        }
        else if(CurrentInstruction == ProgramInstructions.VARIABLE)
        {
            CurrentInstruction = cast(ProgramInstructions)Prog.Body.Body[Mach.ProgramCounter];
        }
        else
        {
            throw new ProgramRunnerException(format("Unknown program instruction: '0x%X' at location 0x%X.", cast(ubyte)CurrentInstruction, Mach.ProgramCounter));
        }
    }
}

void RawValueToStdout(Machine Mach)
{
    ProgramInstructions CurrentInstruction = cast(ProgramInstructions)Mach.Prog.Body.Body[Mach.ProgramCounter];

    if(CurrentInstruction == ProgramInstructions.STRING)
    {
        Mach.ProgramCounter += 1;
        write(GetString(Mach));
    }
    else if(CurrentInstruction == ProgramInstructions.INTEGER)
    {
        Mach.ProgramCounter += 1;
        write(GetInt(Mach));
    }
    else if(CurrentInstruction == ProgramInstructions.VARIABLE)
    {
        Mach.ProgramCounter += 1;
        uint Location = bigEndianToNative!int(cast(ubyte[4])Mach.ReadBytes(4)[0..4]);
        ubyte[] Data = AccessVariable(Mach, Location);
    
        CurrentInstruction = cast(ProgramInstructions)Mach.Prog.Header.PointerTable[Location];

        if(CurrentInstruction == ProgramInstructions.STRING)
        {
            string Str = "";

            for(int i = 0; i < Data.length; i++)
            {
                Str ~= cast(char)Data[i];
            }

            write(Str);
        }
        else if(CurrentInstruction == ProgramInstructions.INTEGER)
        {
            write(bigEndianToNative!int(cast(ubyte[4])Data[0..4]));
        }
    }
    else 
        throw new ProgramRunnerException("Unkown type being streamed to stdout."); 
}

string GetString(Machine Mach, bool IncrementCounter = true)
{
    ubyte StrLength = Mach.Prog.Body.Body[Mach.ProgramCounter];
   
    if(IncrementCounter)
        Mach.ProgramCounter += 1;
    
    string Str = "";

    for(int i = 0; i < StrLength; i++)
    {
        Str ~= cast(char)Mach.Prog.Body.Body[Mach.ProgramCounter];
        
        if(IncrementCounter)
            Mach.ProgramCounter += 1;
    }

    return Str;
}

int GetInt(Machine Mach, bool IncrementCounter = true)
{
    return bigEndianToNative!int(cast(ubyte[4])Mach.ReadBytes(4, IncrementCounter)[0..4]);
}

///TODO: Rewrite, make nicer...
ubyte[] AccessVariable(Machine Mach, int ID)
{
    if(ID >= Mach.Prog.Header.PointerTable.length)
        throw new ProgramRunnerException(format("The pointer table ID is out of bounds. Trying to access (relative) '0x%X'.", ID));

    ubyte[] Return;
    ProgramInstructions Instruction = cast(ProgramInstructions)Mach.Prog.Header.PointerTable[ID];
    ID += 1;

    if(Instruction == ProgramInstructions.INTEGER)
    {
        Return = Mach.Prog.Header.PointerTable[ID..ID + 4];
    }
    else if(Instruction == ProgramInstructions.STRING)
    {
        ubyte StrLength = Mach.Prog.Header.PointerTable[ID];
        ID += 1;      

        Return = Mach.Prog.Header.PointerTable[ID..ID + StrLength];
    }

    return Return;
}

unittest
{
    Machine Mach = new Machine(new Program("Test.svma"));

    int Value = bigEndianToNative!int(cast(ubyte[4])AccessVariable(Mach, 0x00000000)[0..4]);

    assert(Value == 255);
}
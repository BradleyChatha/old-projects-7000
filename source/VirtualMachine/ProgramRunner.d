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
            writeln(Location);
            Mach.ProgramCounter = Location;
        }
        else if(CurrentInstruction == ProgramInstructions.STDOUT)
        {
            RawValueToStdout(Mach);
        }
        else if(CurrentInstruction == ProgramInstructions.VARIABLE)
        {

        }
    }
}

void RawValueToStdout(Machine Mach)
{
    ProgramInstructions CurrentInstruction = cast(ProgramInstructions)Mach.Prog.Body.Body[Mach.ProgramCounter];

    if(CurrentInstruction == ProgramInstructions.STRING)
    {
        Mach.ProgramCounter += 1;
        ubyte StrLength = Mach.Prog.Body.Body[Mach.ProgramCounter];
        Mach.ProgramCounter += 1;
        string Str = "";

        for(int i = 0; i < StrLength; i++)
        {
            Str ~= cast(char)Mach.Prog.Body.Body[Mach.ProgramCounter];
            Mach.ProgramCounter += 1;
        }

        write(Str);
    }
    else if(CurrentInstruction == ProgramInstructions.INTEGER)
    {
        Mach.ProgramCounter += 1;
        int Value = bigEndianToNative!int(cast(ubyte[4])Mach.ReadBytes(4)[0..4]);
        write(Value);
    }
    else 
        throw new ProgramRunnerException("Unkown type being streamed to stdout."); 
}
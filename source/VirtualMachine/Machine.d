module VirtualMachine.Machine;

import std.exception;
import VirtualMachine.Program;

final class Machine
{
    public this(Program Prog)
    {
        this.ProgramCounter = 0;
        this.Prog = Prog;
    }

    public ~this()
    {
        
    }

    public ubyte[] ReadBytes(size_t Amount, bool InceremetCounter = true)
    {
        enforce(this.ProgramCounter + Amount < this.Prog.Body.Body.length, "Cannot read data which is larger than the length of the program body.");

        ubyte[] Return;
        Return = this.Prog.Body.Body[this.ProgramCounter..this.ProgramCounter + Amount];
        
        if(InceremetCounter)
            this.ProgramCounter += Amount;

        return Return;
    }

    public uint ProgramCounter;
    public Program Prog; 
}
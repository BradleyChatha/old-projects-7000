module VirtualMachine.ProgramRunner;

import std.exception;
import std.stdio : File, writeln;
import std.format : format;
import std.array : popFront;
import std.bitmanip : bigEndianToNative;

import VirtualMachine.Machine;
import VirtualMachine.Memory.Stack;

class ProgramRunner
{
    public this(Program Prog)
    {
        this.Prog = Prog;
    }



    private Program Prog;
}
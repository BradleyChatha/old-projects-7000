module VirtualMachine.BackEnd.STDIn;

import std.exception;
import std.stdio : write;

import VirtualMachine.Machine;
import VirtualMachine.MachineInstructions;
import VirtualMachine.Memory.Stack;

class STDInException : Exception
{
    mixin basicExceptionCtors;
}

static class STDIn
{
    public static void ReadIn(Program Prog)
    {
        write("Finish this when write to variable have been finished <3");
    }
}
module VirtualMachine.ProgramRunner;

import std.exception;
import std.stdio : File, writeln;
import std.format : format;
import std.array : popFront;
import std.bitmanip : bigEndianToNative;

import VirtualMachine.Machine;
import VirtualMachine.MachineInstructions;
import VirtualMachine.Memory.Stack;
import VirtualMachine.BackEnd.STDOut;

class ProgramRunnerException : Exception
{
    mixin basicExceptionCtors;
}

class ProgramRunner
{
    public this(Program Prog)
    {
        this.Prog = Prog;
    }

    public void ExecuteProgram()
    {
        while(this.Prog.ProgramBody.Counter < this.Prog.ProgramBody.Length)
        {
            Instruction CurrentInstruction = cast(Instruction)this.Prog.ProgramBody.GetNextByte();

            switch(CurrentInstruction)
            {
                case Instruction.No_Operation:
                    continue;

                case Instruction.STD_Out:
                    STDOut.PushToSTDOut(Prog);
                    break;

                case Instruction.Jump:
                    uint Address = this.Prog.ProgramBody.ByteArrayToType!(uint)();
                    this.Prog.ProgramBody.SetCounterLocation(Address);
                    break;

                default:
                    throw new ProgramRunnerException(format("Unknown program instruction '0x%X'", cast(ubyte)CurrentInstruction));
            }
        }
    }

    private Program Prog;
}
module VirtualMachine.ProgramRunner;

import std.exception;
import std.stdio : File, writeln, readln;
import std.format : format;
import std.array : popFront;
import std.bitmanip : bigEndianToNative;

import VirtualMachine.Machine;
import VirtualMachine.MachineInstructions;
import VirtualMachine.Memory.Stack;
import VirtualMachine.BackEnd.STDOut;
import VirtualMachine.BackEnd.STDIn;
import VirtualMachine.BackEnd.AccessVariable;

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
                    STDOut.PushToSTDOut(this.Prog);
                    break;

                case Instruction.STD_In:
                    STDIn.ReadIn(this.Prog);
                    break;

                case Instruction.Jump:
                    uint Address = this.Prog.ProgramBody.ByteArrayToType!(uint)();
                    this.Prog.ProgramBody.SetCounterLocation(Address);
                    break;

                case Instruction.Variable:
                    VariableUseage Accessor = cast(VariableUseage)this.Prog.ProgramBody.GetNextByte();

                    switch(Accessor)
                    {
                        case VariableUseage.Access:
                            //write(AccessVariable.Access(Prog));
                            break;

                        default:
                            throw new ProgramRunnerException(format("Unkown variable accessor '0x%X'", Accessor));
                    }

                    break;

                default:
                    throw new ProgramRunnerException(format("Unknown program instruction '0x%X'", cast(ubyte)CurrentInstruction));
            }
        }
    }

    private Program Prog;
}
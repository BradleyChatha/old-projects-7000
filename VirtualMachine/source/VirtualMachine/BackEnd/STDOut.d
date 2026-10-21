module VirtualMachine.BackEnd.STDOut;

import std.exception;
import std.stdio : File, writeln, write;
import std.format : format;
import std.array : popFront;
import std.bitmanip : bigEndianToNative;

import VirtualMachine.Machine;
import VirtualMachine.MachineInstructions;
import VirtualMachine.Memory.Stack;
import VirtualMachine.BackEnd.AccessVariable;

class STDOutException : Exception
{
    mixin basicExceptionCtors;
}

static class STDOut
{
    static void PushToSTDOut(Program Prog)
    {
        Instruction IsVariable = cast(Instruction)Prog.ProgramBody.ByteArrayToType!(ubyte)();

        if(IsVariable == Instruction.Variable)
        {
            if(cast(VariableUseage)Prog.ProgramBody.ByteArrayToType!(ubyte)() == VariableUseage.Access)
                write(AccessVariable.Access(Prog));
            else
                throw new STDOutException("Unknown or incorrect accessor");
        }
        else
        {
            DataType Type = cast(DataType)IsVariable;
            switch(Type)
            {
                case DataType.UInteger:
                    write(Prog.ProgramBody.ByteArrayToType!(uint)());                
                    break;

                case DataType.Integer:
                    write(Prog.ProgramBody.ByteArrayToType!(int)());                
                    break;

                case DataType.Float:
                    write(Prog.ProgramBody.ByteArrayToType!(float)());
                    break;

                case DataType.UByte:
                    write(Prog.ProgramBody.ByteArrayToType!(ubyte)());
                    break;

                case DataType.Byte:
                    write(Prog.ProgramBody.ByteArrayToType!(byte)());
                    break;

                case DataType.String:
                    ubyte Length = Prog.ProgramBody.ByteArrayToType!(ubyte)();
                    string Data = "";

                    for(ubyte i = 0; i < Length; i++)
                    {
                        Data ~= Prog.ProgramBody.GetNextByte();
                    }

                    write(Data);
                    break;

                default:
                    throw new STDOutException(format("Unknown type which is being sent to stdout '0x%X'", cast(ubyte)Type));
            }
        }
    }
}
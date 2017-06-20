module VirtualMachine.BackEnd.AccessVariable;

import std.exception;
import std.format : format;
import std.variant;
import std.stdio : write;

import VirtualMachine.Machine;
import VirtualMachine.MachineInstructions;
import VirtualMachine.Memory.Stack;

class AccessVariableException : Exception
{
    mixin basicExceptionCtors;
}

static class AccessVariable
{
    public static Variant Access(Program Prog)
    {
        VariableLocation Location = cast(VariableLocation)Prog.ProgramBody.GetNextByte();

        switch(Location)
        {
            case VariableLocation.PointerTable:
                return AccessPointerTable(Prog);
                

            default:
                throw new AccessVariableException(format("Unknown variable location '0x%X'", Location));
        }
    }

    private static Variant AccessPointerTable(Program Prog)
    {
        uint Address = Prog.ProgramBody.ByteArrayToType!(uint)();

        Prog.PointerTable.SetCounterLocation(Address);
        DataType VariableType = cast(DataType)Prog.PointerTable.GetNextByte();

        switch(VariableType)
        {
            case DataType.String:
                ubyte Length = Prog.PointerTable.ByteArrayToType!(ubyte)();
                string Data = "";

                for(ubyte i = 0; i < Length; i++)
                {
                    Data ~= Prog.PointerTable.GetNextByte();
                }
                return cast(Variant)Data;

            case DataType.UInteger:
                return cast(Variant)Prog.PointerTable.ByteArrayToType!(uint)();

            case DataType.Integer:
                return cast(Variant)Prog.PointerTable.ByteArrayToType!(int)();

            case DataType.Float:
                return cast(Variant)Prog.PointerTable.ByteArrayToType!(float)();

            case DataType.UByte:
                return cast(Variant)Prog.PointerTable.ByteArrayToType!(ubyte)();

            case DataType.Byte:
                return cast(Variant)Prog.PointerTable.ByteArrayToType!(byte)();

            default:
                throw new AccessVariableException(format("Cannot access unkown data type '0x%X'.", VariableType));
        }
    }
}
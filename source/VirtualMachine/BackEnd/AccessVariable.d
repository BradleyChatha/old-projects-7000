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


            default:
                throw new AccessVariableException(format("Cannot access unkown data type '0x%X'.", VariableType));
        }
    }
}
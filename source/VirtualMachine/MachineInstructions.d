module VirtualMachine.MachineInstructions;

enum Instruction : ubyte
{
    No_Operation = 0x00,
    STD_In,
    STD_Out,
    Jump,
    Variable,

    Instruction_Max    
}

enum DataType : ubyte
{
    UInteger = cast(ubyte)Instruction.Instruction_Max,
    Integer,
    Float,
    UByte,
    Byte,
    String,

    DataType_Max
}

enum VariableUseage : ubyte
{
    Access = cast(ubyte)DataType.DataType_Max,
    Modify,

    VariableUseage_Max,
}

enum VariableLocation : ubyte
{
    PointerTable = cast(ubyte)VariableUseage.VariableUseage_Max,
    Stack
}
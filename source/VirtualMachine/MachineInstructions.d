module VirtualMachine.MachineInstructions;

enum Instruction : ubyte
{
    No_Operation = 0x00,
    STD_In,
    STD_Out,
    Jump,
    Variable
}

enum DataType : ubyte
{
    UInteger = 0x00,
    Integer,
    Float,
    UByte,
    Byte,
    String
}

enum VariableUseage : ubyte
{
    Access = 0x00,
    Modify
}

enum VariableLocation : ubyte
{
    PointerTable = 0x00,
    Stack
}
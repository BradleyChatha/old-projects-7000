module VirtualMachine.MachineInstructions;

enum Instruction : ubyte
{
    No_Operation = 0x00,
    STD_In,
    STD_Out,
    Jump
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
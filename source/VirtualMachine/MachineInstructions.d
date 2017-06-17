module VirtualMachine.MachineInstructions;

enum Instruction : ubyte
{
    No_Operation = 0x00,
    STD_In,
    STD_Out,
    Jump
}
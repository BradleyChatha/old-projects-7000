import std.stdio;

import VirtualMachine.Machine;
import VirtualMachine.ProgramRunner;

void main()
{
    Program Prog = new Program("Test.SVMA");
    ProgramRunner Runner = new ProgramRunner(Prog);
    Runner.ExecuteProgram();
}

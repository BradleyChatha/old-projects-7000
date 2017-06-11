import std.stdio;
import VirtualMachine.Machine;
import VirtualMachine.Program;
import VirtualMachine.ProgramRunner;

void main()
{
	Program Prog = new Program("Test.SVMA");
    Machine Mach = new Machine(Prog);

    RunProgram(Mach);
}

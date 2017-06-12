import std.stdio, std.file;
import sasm.compiler;

void main()
{
	auto compiler = new Compiler(".Main: print string \"Hello\\nWorld!\"\njump label .Main:");
	std.file.write("Test.svma", compiler.compile);
}
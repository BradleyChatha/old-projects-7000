import std.stdio, std.file;
import sasm.compiler;

void main()
{
	auto compiler = new Compiler(".Main: print string \"Hello\\nWorld!\"\nnop");
	std.file.write("Test.svma", compiler.compile);
}
import std.stdio, std.file, std.getopt;
import sasm.compiler;

void main(string[] args)
{
	string inputFile;
	string outputFile;

	auto info = args.getopt(
		config.passThrough,

		"output|o", "The file to write the output to.", &outputFile,
		"input|i",  "The file to read the input from.", &inputFile
	);

	if(outputFile is null)
		outputFile = "a.svma";

	if(inputFile is null)
	{
		if(args.length == 1)
		{
			writeln("Expected at least one argument, which is the input file.");
			return;
		}

		inputFile = args[1];
	}

	if(info.helpWanted)
	{
		defaultGetoptPrinter("Usage: assembler input.sasm -o output.svma", info.options);
		return;
	}

	auto compiler = new Compiler(std.file.readText!string(inputFile));
	
	std.file.write(outputFile, compiler.compile);
}
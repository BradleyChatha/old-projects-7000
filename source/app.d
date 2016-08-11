module app;

import std.stdio, std.file, std.format;
import jasm.compiler, jasm.reader, jasm.vm, jasm.grammar;

void main()
{
    version(unittest)
    {
        import std.path;

        chdir("bin");
    }

    auto code = readText("Test.jasm");
    auto tree = code.parseJasm;
    std.file.write("Debug.txt", tree.toString);

    auto comp = new Compiler();
    comp.include(tree);
    auto bin  = comp.compile;

    std.file.write("Test.bin", bin);

    auto reader = JExeReader!(ubyte[])(bin);

    version(unittest)
    {
        chdir(buildNormalizedPath(getcwd(), ".."));
    }
}
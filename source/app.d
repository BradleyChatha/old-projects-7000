module app;

import std.stdio, std.file, std.format;
import jasm.lexer, jasm.compiler, jasm.ast, jasm.reader, jasm.vm;

void main()
{
    version(unittest)
    {
        import std.path;

        chdir("bin");
    }


    version(unittest)
    {
        chdir(buildNormalizedPath(getcwd(), ".."));
    }
}
module app;

import std.stdio, std.file, std.format;
import jasm.lexer, jasm.compiler, jasm.ast;

void main()
{
    version(unittest)
    {
        import std.path;

        chdir("bin");
    }

    auto lex = new Lexer(readText("Test.jasm"), "Test.jasm");
    std.file.write("Test.bin", compileJasm([nextNamespace(lex)]));

    version(unittest)
    {
        chdir(buildNormalizedPath(getcwd(), ".."));
    }
}
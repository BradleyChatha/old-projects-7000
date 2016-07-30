module app;

import std.stdio, std.file, std.format;
import jasm.lexer, jasm.compiler, jasm.ast, jasm.reader;

void main()
{
    version(unittest)
    {
        import std.path;

        chdir("bin");
    }

    auto lex      = new Lexer(readText("Test.jasm"), "Test.jasm");
    auto compiler = new Compiler();
    compiler.include(lex.parseCode);
    auto bytes    = compiler.compile();
    std.file.write("Test.bin", bytes);

    writeln(JExeReader!(ubyte[])(bytes));

    version(unittest)
    {
        chdir(buildNormalizedPath(getcwd(), ".."));
    }
}
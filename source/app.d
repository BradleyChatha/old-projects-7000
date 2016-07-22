module app;

import std.stdio, std.file, std.format;
import jasm.lexer;

void main()
{
    version(unittest)
    {
        import std.path;

        chdir("bin");
    }

    auto lex = new Lexer(readText!string("Test.jasm"), "Test.jasm");

    string f = "";
    foreach(token; lex)
    {
        f ~= format("%s\n", token);
    }

    std.file.write("Tokens.txt", f);

    version(unittest)
    {
        chdir(buildNormalizedPath(getcwd(), ".."));
    }
}
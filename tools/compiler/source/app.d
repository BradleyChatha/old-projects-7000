module app;

import std.stdio, std.file, std.format;
import jasm.compiler, jasm.reader, jasm.grammar;

void main()
{
    version(unittest)
    {
        import std.path;
        
        chdir("bin");
    }
    
    auto tree = code.parseJasm;
    std.file.write("Debug.txt", tree.toString);
    
    auto comp = new Compiler();
    comp.include(tree);
    auto bin  = comp.compile;
    
    std.file.write("Test.bin", bin);
    
    auto reader = bin.readJExe();
    
    version(unittest)
    {
        chdir(buildNormalizedPath(getcwd(), ".."));
    }
}

string code = 
    r"
.namespace Jasm.Test

.class Test [Static]
{
    .function Main() &void [EntryPoint]
    {
        .locals
        {
            &string // 0
        }
        
        push.str 'Daniel is a moob';
        store.local 0;
        
        debug.locals; // Prints out all of the locals in the function.
    }
}    
";
module jasm.grammar;

public
{
    import pegged.grammar;
}

// This grammar is used to first remove any comments
mixin(grammar(r"
JasmUncommented:
    Text    <- :Comment / ~(. Text)*
    Comment <- :'//' (!eol .)*
"));

// Then this grammar can be used to properly parse it
mixin(grammar(r"
Jasm:
    # Entire file
    Code < Namespace ClassDeclaration*

    # Namespace
    Namespace < :'.namespace' qualifiedIdentifier

    # Classes
                                 #Name       #Attributes
    ClassDeclaration < :'.class' ^identifier Attribute*
                       :'{'
                            FunctionDeclaration*    # Functions
                       :'}'

    # Functions
                                        #Name           #ParamTypes   #ReturnType #Attributes
    FunctionDeclaration < :'.function' ^identifier :'(' VarType* :')' VarType     Attribute*
                          :'{'
                                LocalsDeclaration   #LocalTypes
                                MneumonicStatement* #Operations
                          :'}'

    # Attributes
    Attribute < :'[' identifier :']'

    # .locals
    LocalsDeclaration < :'.locals' :'{' VarType* :'}'

    # VarType
    VarType < :'&' identifier

    # Mneumonics
    MneumonicStatement < Mneumonic MneumonicOperand? (',' MneumonicOperand)* :';'
    MneumonicOperand   < String / Number
    Mneumonic < 'push.str'          /
                'push.i32'          /
                'store.local'       /
                'debug.locals'      

    # Number
    Number < HexNum / DecNum
    DecNum <~ digit+
    HexNum <~ '0x' hexDigit+

    # String
    String <- :Quote ~(!Quote SChar)* :Quote
    Quote  <- (quote / doublequote)
    SChar  <- backslash ('r' / 't' / 'n' / backslash / quote / doublequote) / .
"));
unittest
{
    import std.stdio, std.file;

    auto tree = parseJasm(
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
");
    //std.file.write("Debug.txt", tree.toString);
}

/++
 + Parses a piece of JASM code.
 + 
 + Throws:
 +  `Exception` if something about `code` is invalid.
 + 
 + Params:
 +  code = The code to parse.
 + 
 + Returns:
 +  A `ParseTree` containing the tree of the parsed `code`.
 + ++/
@trusted
ParseTree parseJasm(string code)
{
    import std.exception : enforce;

    auto jc = JasmUncommented(code);
    assert(jc.successful, "Unable to uncomment Jasm: " ~ jc.failMsg);
    assert(jc.matches.length == 1, "Too many matches: " ~ jc.toString);

    auto j = Jasm(jc.matches[0]);
    enforce(j.successful, new Exception("Failure parsing Jasm: " ~ j.failMsg));

    return j;
}
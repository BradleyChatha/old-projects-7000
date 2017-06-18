module sasm.parser.grammar;

import pegged.grammar, pegged.tester.grammartester;

// This grammar is used to first remove any comments
mixin(grammar(r"
SasmUncommented:
    Text    <- :Comment / ~(. Text)*
    Comment <- :'//' (!eol .)*
"));

// The main grammar
mixin(grammar(`
Sasm:
    Code < (Label / Mneumonic / Variable)+

    # Mneumonics
    Mneumonic < Mne_Print /
                Mne_Nop   /
                Mne_Jump

    Mne_Print < :'print' Value
    Mne_Jump  < :'jump' Val_Label
    Mne_Nop   < 'nop'

    # Variable declaration
    Variable < :'declare' identifier Value

    # Data Values
    Value  <- String        /
              Int8          /
              UInt8         /
              Int32         /
              UInt32        /
              Float32       /
              Val_Label     /
              Val_Variable

    String       < :'string'    ;Lit_String
    Int32        < :'int32'     ;Lit_Integer
    UInt32       < :'uint32'    ;Lit_Integer
    Int8         < :'int8'      ;Lit_Integer
    UInt8        < :'uint8'     ;Lit_Integer
    Float32      < :'float'     ;Lit_Float
    Val_Label    < :'label'     ;Label
    Val_Variable < :'variable'  ;identifier

    # Data Literals
    Lit_String  < :doublequote ~(!doublequote Character)* :doublequote
    Lit_Integer < digits
    Lit_Float   <~ digits ('.' digits)? :'f'
    
    # Character handling
    Character < ;EscapedCharacter / .
    EscapedCharacter <~ backslash ('n' / 'r' / backslash / doublequote)

    # .SomeLabelName: -> 'SomeLabelName'
    Label < :'.' identifier :Colon
    Colon < ':'
`));

unittest
{
    auto test = new GrammarTester!(Sasm, "Label");
    test.assertSimilar(".LoopStart:", "Label");
}

unittest
{
    import std.format : format;

    auto test = new GrammarTester!(Sasm, "Character");
    test.assertSimilar("\\n", "Character");
    test.assertSimilar("a",   "Character");

    auto matches = Sasm.Character("\\n");
    assert(matches.successful);
    assert(matches.matches[0] == "\\n", format("%s", matches.matches));
}

unittest
{
    auto test = new GrammarTester!(Sasm, "Lit_String");
    test.assertSimilar("\"This is a string literal\"", "Lit_String");

    assert(Sasm.Lit_String("\"Hello\\nWorld!\"").matches[0] == "Hello\\nWorld!");
}

unittest
{
    auto test = new GrammarTester!(Sasm, "Lit_Integer");
    test.assertSimilar("129213", "Lit_Integer");
}

unittest
{
    auto test = new GrammarTester!(Sasm, "Lit_Float");
    test.assertSimilar("2053f",    "Lit_Float");
    test.assertSimilar("2053.69f", "Lit_Float");
}

unittest
{
    auto test = new GrammarTester!(Sasm,   "Value");
    test.assertSimilar("string \"Hello\"", "Value->String");
    test.assertSimilar("int32 25120",      "Value->Int32");
}

unittest
{
    auto test = new GrammarTester!(Sasm, "Mneumonic");
    test.assertSimilar("print int32 200", "Mneumonic->Mne_Print->Value->Int32");
}

/++
 + Parses a piece of SASM code.
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
ParseTree parseSasm(string code)
{
    import std.exception : enforce;

    auto sc = SasmUncommented(code);
    assert(sc.successful, "Unable to uncomment Sasm: " ~ sc.failMsg);
    assert(sc.matches.length == 1, "Too many matches: " ~ sc.toString);

    auto s = Sasm(sc.matches[0]);
    enforce(s.successful, new Exception("Failure parsing Sasm: " ~ s.failMsg));

    debug
    {
        import std.stdio : writefln;

        writefln("Error message (even if there's not an error): %s", s.failMsg);
    }

    return s;
}
unittest
{
    import sasm.parser.ast;

    auto tree = parseSasm(`
        declare Six int32 6

        .Main:
            print string "Hello\nWorld!"
            print int32  2013
            print float  2013f
            print float  2013.13f
            print variable Six
            nop
            jump label .Main:
    `);

    import std.stdio;
    writeln(tree);
    writeln(tree.treeToAst);
}
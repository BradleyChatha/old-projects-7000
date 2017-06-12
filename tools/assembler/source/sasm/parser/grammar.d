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
    Code < (Label / Mneumonic)*

    # Mneumonics
    Mneumonic <- Mne_Print

    Mne_Print < :'print' Value

    # Data Values
    Value  <- String /
              Int32

    String < :'string' ;Lit_String
    Int32  < :'int32'  ;Lit_Integer  

    # Data Literals
    Lit_String  <- :doublequote ~(!doublequote Character)* :doublequote
    Lit_Integer <  digits
    
    # Character handling
    Character <- ;EscapedCharacter / .
    EscapedCharacter <~ backslash ('n' / 'r' / backslash / doublequote)

    # .SomeLabelName: -> 'SomeLabelName'
    Label <- :'.' identifier :Colon
    Colon <- ':'
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

    return s;
}
unittest
{
    import sasm.parser.ast;

    auto tree = parseSasm(`
        .Main:
            print string "Hello world!\n"
            print int32  69
            print string "\nPlease update this test once the grammar is more complete!"
    `);

    import std.stdio;
    writeln(tree);
    writeln(tree.treeToAst);
}
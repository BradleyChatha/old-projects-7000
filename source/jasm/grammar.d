module jasm.grammar;

private
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
    # .locals
    LocalsDeclaration < :'.locals' :'{' VarType* :'}'

    # VarType
    VarType < :'&' identifier

    # Mneumonics
    MneumonicStatement < Mneumonic MnuemonicOperand? (',' MnuemonicOperand)* :';'
    MnuemonicOperand   < String / Number
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
    import std.stdio;

    auto tree = parseJasm("");
    writeln(tree);
}

/++
 + 
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
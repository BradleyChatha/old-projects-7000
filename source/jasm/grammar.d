module jasm.grammar;

private
{
    import pegged.grammar;
}

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

    auto tree = Jasm(".locals {&int32 &string}");
    writeln(tree);
}
module jasm.opcodes;

private
{
    import jasm.lexer;
}

/++
 + Flags about a class.
 + ++/
enum ClassFlags : ubyte
{
    /++
     + If a class is static, then only a single instance of the class exists, and any of it's functions all use this single instance.
     + 
     + This forces any functions in the class to also be IsStatic
     + ++/
    IsStatic = 1 << 0
}

/++
 + Flags about a function.
 + ++/
enum FuncFlags : ubyte
{
    /++
     + If a function is static, then the VM should make a static instance of a class that all static functions use.
     + 
     + This does not mean that a class is forced to be IsStatic
     + ++/
    IsStatic = 1 << 0,

    /++
     + If a function is the entry point, then the VM will first call that function to start the program.
     + 
     + There may only be one function marked as the entry point
     + ++/
    IsEntry  = 1 << 1
}

/++
 + Contains all of the opcodes used in a JEXE.
 + ++/
enum Opcode : ubyte
{
    /++
     + Command:
     +  debug.locals
     + 
     + Description:
     +  Causes the VM to output the values of the function's local variables.
     + ++/
    DEBUG_LOCALS = 4
}

/++
 + Converts a `TokenType` into an `Opcode`.
 + 
 + Parameters:
 +  type = The type to convert.
 + 
 + Returns:
 +  The `Opcode` Equivalent to `type`
 + ++/
Opcode toOpcode(TokenType type)
{
    assert(type > TokenType.CODE_START && type < TokenType.CODE_END);

    auto a = cast(ushort)type;
    auto b = cast(ushort)TokenType.CODE_START;
    return cast(Opcode)(a - b);
}
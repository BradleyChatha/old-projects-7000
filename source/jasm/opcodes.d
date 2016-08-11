module jasm.opcodes;

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
 + 
 + This documentation for the `Opcode` values is talking about
 + how the VM should function, instead of how it works inside of JASM.
 + ++/
enum Opcode : ubyte
{
    /++
     + Command:
     +  push.str
     + 
     + Description:
     +  Pushes a string value onto the top of the stack.
     + 
     + Params:
     +  [0] UInt32 = The index in the String table of which string to push.
     + ++/
    PUSH_STR                    = 1,

    /++
     + Command:
     +  push.i32
     + 
     + Description:
     +  Pushes a 32-bit signed integer onto the top of the stack.
     + 
     + Params:
     +  [0] Int32 = The interger to push onto the stack.
     + ++/
    PUSH_I32                    = 2,

    /++
     + Command:
     +  store.local
     + 
     + Description:
     +  Pops the stack and stores the popped off value into a local variable.
     + 
     + Exceptions:
     +  An TODO: Make exception name, should be thrown if the type of the popped off value is not convertable to
     +  the type of the local variable.
     + 
     + Params:
     +  [0] UInt8 = The index of the local variable to store the value into.
     + ++/
    STORE_LOCAL                 = 3,

    /++
     + Command:
     +  debug.locals
     + 
     + Description:
     +  Causes the VM to output the values of the function's local variables.
     + ++/
    DEBUG_LOCALS                = 4
}
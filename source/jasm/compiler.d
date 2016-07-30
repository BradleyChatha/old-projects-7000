module jasm.compiler;

private
{
    import std.array     : appender, Appender;
    import std.bitmanip;
    import std.exception : enforce;
    import std.stdio     : File;
    import std.traits    : isArray, isSomeString;

    import jasm.ast, jasm.opcodes, jasm.lexer;
}

/++
 + This class will be able to compile JASM code into the JEXE format.
 + ++/
class Compiler
{
    public static immutable
    {
        /++
         + The "magic number" of a JEXE.
         + ++/
        char[4] fileHeader  = "JEXE";

        /++
         + The version of the JEXE format that the compiler outputs.
         + ++/
        ushort  fileVersion = 0x0001;
    }

    private
    {
        FileNode[]          _files;
        ubyte[]             _output;
        size_t              _index;
        FuncInfo[string]    _funcDefs; // The key is the function's signature.

        // Used to keep track of the positions of a function's pointer and size bytes.
        struct FuncInfo
        {
            size_t  pointerPtr;
            size_t  sizePtr;
        }

        void write(const(void)[] data)
        {
            if(this._output.capacity == this._output.length)
                this._output.reserve(ubyte.max); // No real rason for ubyte.max, just felt like it

            auto old     = this._index;
            this._index += data.length;

            // Add to the length of _output, so we don't get a RangeError
            if(this._index > this._output.length)
                this._output.length += (this._index - this._output.length);

            this._output[old..this._index] = cast(ubyte[])data[0..$];
        }

        void write(S, Prefix)(S data)
        if(isSomeString!S)
        {
            this.write(cast(Prefix)data.length);
            this.write(data);
        }

        void write(T)(T data)
        if(!isArray!T && !is(T == class))
        {
            this.write((&data)[0..1]);
        }

        alias writeString8  = write!(string, ubyte);
        alias writeString16 = write!(string, ushort);
    }

    public
    {
        /++
         + Includes a file to be compiled.
         + 
         + Exceptions:
         +  $(D file) must not be `null`.
         +  $(D file) must not have already been included.
         + 
         + Parameters:
         +  file = The node of the file to include.
         + ++/
        void include(FileNode file)
        {
            import std.algorithm : all;

            enforce(file !is null,                      new CompileException("Attempted to include a null FileNode"));
            enforce(this._files.all!((f) => f != file), new CompileException("This FileNode has already been included."));

            this._files ~= file;
        }

        /++
         + Compiles all of the included files into a JEXE.
         + 
         + Throws:
         +  `CompileException` if something goes wrong.
         + 
         + Returns:
         +  The bytes making up the JEXE.
         + ++/
        ubyte[] compile()
        {
            import std.algorithm : each;

            this.writeHeader();
            this._files.each!((f) => this.writeNamespaceDef(f.namespace));

            return this._output;
        }
    }

    // All the functions for actually writing certain data.
    private
    {
        // Writes <Header> as defined in the format specifitation.
        void writeHeader()
        {
            this.write(Compiler.fileHeader[]);
            this.write(Compiler.fileVersion);
            this.write(cast(ubyte)0);
        }

        // <FunctionDef>
        void writeFunctionDef(FunctionNode func)
        {
            this.writeString16(func.signature);
            this.writeString16(func.params.asList);

            ubyte flag = 0;
            foreach(attr; func.attributes)
            {
                switch(attr.token.text)
                {
                    case "Static":      flag |= FuncFlags.IsStatic; break;
                    case "EntryPoint":  flag |= FuncFlags.IsEntry; break;

                    default:
                        throw new CompileException("Invalid attribute: " ~ attr.token.text);
                }
            }

            this.write(flag);

            this._funcDefs[func.signature] = FuncInfo(this._index, this._index + uint.sizeof);
            this.write(cast(uint)0); // Save space for the pointer
            this.write(cast(uint)0); // Save space for the size
        }

        // <ClassDef>
        void writeClassDef(ClassNode cls)
        {
            import std.algorithm : each;
            this.writeString8(cls.name);

            ubyte flag = 0;
            foreach(attr; cls.attributes)
            {
                switch(attr.token.text)
                {
                    case "Static": flag |= ClassFlags.IsStatic; break;

                    default:
                        throw new CompileException("Invalid attribute: " ~ attr.token.text);
                }
            }

            this.write(cast(uint)cls.functions.length);
            cls.functions.each!((f) => this.writeFunctionDef(f));
        }

        // <NamespaceDef>
        void writeNamespaceDef(NamespaceNode ns)
        {
            import std.algorithm : each;
            this.writeString8(ns.name.fullName);

            this.write(cast(uint)ns.classes.length);
            ns.classes.each!((c) => this.writeClassDef(c));
        }
    }
}
///
unittest
{
    auto comp = new Compiler();
    auto lex  = new Lexer(r"
    .namespace Test/Namespace; 
    
    .class Example 
    { 
        .function Pls(&string &int32) &void [Static] [EntryPoint] 
        {
            .locals 
            {
                &int32
                &int32
            }
        } 
    }");

    import std.file;
    comp.include(lex.parseCode);

    auto output = comp.compile();
    write("Debug.jexe", output);
}

/// The exception that is thrown by the Compiler.
class CompileException : Exception
{
    public
    {
        /++
         + Creates a new CompileException.
         + 
         + Parameters:
         +  msg = The error message.
         + ++/
        @safe
        this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
        {
            super(msg, file, line, next);
        }
    }
}
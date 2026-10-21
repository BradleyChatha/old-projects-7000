module jasm.compiler;

private
{
    import std.algorithm : filter, map;
    import std.array     : appender, Appender;
    import std.bitmanip;
    import std.exception : enforce;
    import std.stdio     : File;
    import std.traits    : isArray, isSomeString;
    import std.format    : format;

    import jasm.grammar, jasm.opcodes;
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
        ParseTree[]         _files;
        ubyte[]             _output;
        size_t              _index;
        FuncInfo[string]    _funcDefs; // The key is the function's signature.
        string[]            _strings;

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
        this()
        {
            this.setupOpcodes();
        }

        /++
         + Includes a piece of code to be compiled.
         + 
         + Exceptions:
         +  $(D tree)'s name must be "Jasm"
         +  $(D tree) must not have already been included.
         + 
         + Params:
         +  tree = The parse tree of the code.
         + ++/
        void include(ParseTree tree)
        {
            import std.algorithm : all;

            enforce(tree.name == "Jasm" && tree.children[0].name == "Jasm.Code");
            enforce(this._files.all!((f) => f.input != tree.input), new CompileException("This ParseTree has already been included."));

            this._files ~= tree.children[0];
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
            this.writeHeader();
            this.writeOpcodes();
            this.writeStringTable();

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

        // Writes the string table.
        void writeStringTable()
        {
            this.write(cast(uint)this._strings.length);
            foreach(str; this._strings)
                this.writeString16(str);
        }

        // <FunctionDef>
        void writeFunctionDef(ParseTree func)
        {
            import std.array : array;
            assert(func.name == "Jasm.FunctionDeclaration", func.name);

            // Get all the information about the function
            auto name       = func.children.filter!((c) => c.name == "identifier").front.matches[0];
            auto types      = func.children.filter!((c) => c.name == "Jasm.VarType").map!((c) => c.matches[0]).array;
            auto attribs    = func.children.filter!((c) => c.name == "Jasm.Attribute").map!((c) => c.matches[0]);
            auto locals     = func.children.filter!((c) => c.name == "Jasm.LocalsDeclaration").front.matches;
            auto sig        = name.asFunctionSignature(types);

            this.writeString16(sig);
            this.writeString16(locals.asVarTypeList);

            ubyte flag = 0;
            foreach(attr; attribs)
            {
                switch(attr)
                {
                    case "Static":      flag |= FuncFlags.IsStatic; break;
                    case "EntryPoint":  flag |= FuncFlags.IsEntry; break;

                    default:
                        throw new CompileException("Invalid attribute: " ~ attr);
                }
            }

            this.write(flag);

            this._funcDefs[sig] = FuncInfo(this._index, this._index + uint.sizeof);
            this.write(cast(uint)0); // Save space for the pointer
            this.write(cast(uint)0); // Save space for the size
        }

        // <ClassDef>
        void writeClassDef(ParseTree cls)
        {
            import std.algorithm : each;
            import std.array     : array;
            assert(cls.name == "Jasm.ClassDeclaration", cls.name);

            // Get all the information about the class
            auto name       = cls.children.filter!((c) => c.name == "identifier").front.matches[0];
            auto attribs    = cls.children.filter!((c) => c.name == "Jasm.Attribute").map!((c) => c.matches[0]);
            auto functions  = cls.children.filter!((c) => c.name == "Jasm.FunctionDeclaration").array;

            this.writeString8(name);

            ubyte flag = 0;
            foreach(attr; attribs)
            {
                switch(attr)
                {
                    case "Static": flag |= ClassFlags.IsStatic; break;

                    default:
                        throw new CompileException("Invalid attribute: " ~ attr);
                }
            }

            this.write(flag);
            this.write(cast(uint)functions.length);
            functions.each!((f) => this.writeFunctionDef(f));
        }

        // <NamespaceDef>
        void writeNamespaceDef(ParseTree ns)
        {
            import std.algorithm : each;
            import std.array     : array;
            assert(ns.name == "Jasm.Code");

            auto name       = ns.children.filter!((c) => c.name == "Jasm.Namespace").front.matches[0];
            auto classes    = ns.children.filter!((c) => c.name == "Jasm.ClassDeclaration").array;

            this.writeString8(name);

            this.write(cast(uint)classes.length);
            classes.each!((c) => this.writeClassDef(c));
        }

        // <Opcodes[]>
        void writeOpcodes()
        {
            import std.algorithm : each;

            // TODO: Merge the same namespaces into a single FileNode
            this.write(cast(uint)this._files.length);
            this._files.each!((f) => this.writeNamespaceDef(f));
            
            // Write out all of the opcodes            
            auto old = this._index;
            this.write(cast(uint)0); // Reserve space for the Opcode section size.

            auto opStart = this._index;
            foreach(file; this._files)
                foreach(cls; file.children.filter!((c) => c.name == "Jasm.ClassDeclaration"))
                    foreach(func; cls.children.filter!((c) => c.name == "Jasm.FunctionDeclaration"))
                        this.writeFunctionBody(func, opStart);
        
            // And then how many bytes they take up
            auto otherOld = this._index;
            this._index = old;
            this.write(cast(uint)((otherOld - uint.sizeof) - old));
            this._index = otherOld;
        }

        // <Opcodes[]>
        void writeFunctionBody(ParseTree func, uint opcodeStart)
        {
            import std.array : array;

            // Information about the function
            auto name       = func.children.filter!((c) => c.name == "identifier").front.matches[0];
            auto types      = func.children.filter!((c) => c.name == "Jasm.VarType").map!((c) => c.matches[0]).array;
            auto sig        = name.asFunctionSignature(types);

            // Write the pointer
            auto funcInfo = this._funcDefs[sig];
            auto start    = this._index;
            this._index   = funcInfo.pointerPtr;
            this.write(cast(uint)(start - opcodeStart)); // The pointer is relative to the first opcode, not the start of the file
            this._index   = start;

            foreach(op; func.children.filter!((c) => c.name == "Jasm.MneumonicStatement"))
            {
                import std.array  : replace;
                import std.conv   : to;
                import std.string : toUpper;

                // Find the information about the opcode
                auto code = op.matches[0].replace(".", "_").toUpper.to!Opcode;
                auto info = this._opcodes[code];

                this.write(cast(ubyte)code);

                // Make sure there's enough parameters
                auto parameters = op.children.filter!((c) => c.name == "Jasm.MneumonicOperand").array;

                enforce(parameters.length == info.params.length, 
                    new CompileException(
                        format("Expected %s parameters for %s, but only got %s", 
                                info.params.length, op.matches[0], parameters.length)
                        ));
                foreach(i, param; info.params)
                {
                    auto given = parameters[i];
                    auto type  = given.children[0].name;

                    // Make sure the parameters are of the right type
                    // The First byte of an Opcode.Param value is metadata, so it is ANDed to only get the parameter's type.
                    enforce(
                            (type == "Jasm.String" && param == OpcodeInfo.Param.String)
                         || (type == "Jasm.Number" && ((param & 0x00FF) >= OpcodeInfo.Param.Int8 && (param & 0x00FF) <= OpcodeInfo.Param.Int32)),
                            new CompileException(format("For opcode %s, expected a %s as the %sst/nd/th opcode, but got %s", code, param, i, type))
                        );

                    switch(type)
                    {
                        case "Jasm.String":
                            this.write(this.makeStringTableEntry(given.matches[0]));
                            break;

                        case "Jasm.Number":
                            auto x = given.matches[0];
                            if(param & OpcodeInfo.Param.Unsigned)
                                this.writeNumberParameter!false(x, param);
                            else
                                this.writeNumberParameter!true(x, param);
                            break;

                        default: assert(0);
                    }
                }
            }

            // Write the size
            auto end        = this._index;
            this._index     = funcInfo.sizePtr;
            this.write(cast(uint)(end - start));
            this._index     = end;
        }

        /// Returns:
        ///     The index of the string
        uint makeStringTableEntry(string str_)
        {
            foreach(i, str; this._strings)
                if(str == str_)
                    return i;

            this._strings ~= str_;
            return cast(uint)(this._strings.length - 1);
        }

        void writeNumberParameter(bool signed)(string numText, OpcodeInfo.Param numType)
        {
            T validateNumber(T, OpcodeInfo.Param Num)()
            {
                import std.conv : to;

                static if(!signed)
                    enforce(numText[0] != '-', new CompileException("Expected a non-negative number."));

                static if(signed)
                    long value = numText.to!long;
                else
                    ulong value = numText.to!ulong;

                static if(Num == OpcodeInfo.Param.Int8)
                    enum max = byte.max;
                else static if(Num == OpcodeInfo.Param.Int16)
                    enum max = short.max;
                else static if(Num == OpcodeInfo.Param.Int32)
                    enum max = int.max;

                static if(signed)
                    enforce(value <= max && value >= -(max + 1), 
                        new CompileException(format("Value is too large/too small. Min = %s, Max = %s, Got = %s", -(max + 1), max, value)));
                else
                    enforce(value <= (max * 2) + 1, new CompileException(format("Value is too large. Min = 0, Max = %s, Got = %s", (max * 2) + 1, value)));

                return cast(T)value;
            }

            switch(numType & 0x00FF) with(OpcodeInfo.Param)
            {
                case Int8:  this.write(validateNumber!(ubyte,  Int8));  break;
                case Int16: this.write(validateNumber!(ushort, Int16)); break;
                case Int32: this.write(validateNumber!(uint,   Int32)); break;

                default:
                    assert(0);
            }
        }

        struct OpcodeInfo
        {
            enum Param : ushort
            {
                None        = 0,
                String      = 0x0001,
                Int8        = 0x0002,
                Int16       = 0x0003,
                Int32       = 0x0004,
                Unsigned    = 0xFF00,

                UInt8       = Int8  | Unsigned,
                UInt16      = Int16 | Unsigned,
                UInt32      = Int32 | Unsigned
            }

            Param[] params;
        }
        OpcodeInfo[Opcode] _opcodes;
        void setupOpcodes()
        {
            with(OpcodeInfo.Param)
            {
                this._opcodes =
                [
                    Opcode.PUSH_STR:                OpcodeInfo([String]),
                    Opcode.PUSH_I32:                OpcodeInfo([Int32]),
                    Opcode.STORE_LOCAL:             OpcodeInfo([UInt8]),
                    Opcode.DEBUG_LOCALS:            OpcodeInfo([])
                ];
            }
        }
    }
}

/// The exception that is thrown by the Compiler.
class CompileException : Exception
{
    public
    {
        /++
         + Creates a new CompileException.
         + 
         + Params:
         +  msg = The error message.
         + ++/
        @safe
        this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
        {
            super(msg, file, line, next);
        }
    }
}

private string asVarTypeList(string[] types)
{
    string list;
    foreach(type; types)
        list ~= "&" ~ type;

    return list;
}

private string asFunctionSignature(string funcName, string[] types)
{
    auto sig = funcName;
    foreach(i, type; types)
        sig ~= (i == types.length - 1) ? "$" ~ type : "&" ~ type;

    return sig;
}
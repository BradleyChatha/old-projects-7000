module jasm.compiler;

private
{
    import std.array     : appender, Appender;
    import std.bitmanip;
    import std.exception : enforce;
    import std.stdio     : File;
    import std.traits    : isArray, isSomeString;
    import std.format    : format;

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
        void writeFunctionDef(FunctionNode func)
        {
            this.writeString16(func.signature);
            this.writeString16(func.locals.asList);

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

            this.write(flag);
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

        // <Opcodes[]>
        void writeOpcodes()
        {
            import std.algorithm : each, map;

            // TODO: Merge the same namespaces into a single FileNode
            this.write(cast(uint)this._files.length);
            this._files.each!((f) => this.writeNamespaceDef(f.namespace));
            
            // Write out all of the opcodes            
            auto old = this._index;
            this.write(cast(uint)0); // Reserve space for the Opcode section size.
            
            foreach(file; this._files)
                foreach(cls; file.namespace.classes)
                    foreach(func; cls.functions)
                        this.writeFunctionBody(func);
            
            // And then how many bytes they take up
            auto otherOld = this._index;
            this._index = old;
            this.write(cast(uint)((otherOld - uint.sizeof) - old));
            this._index = otherOld;
        }

        // <Opcodes[]>
        void writeFunctionBody(FunctionNode func)
        {
            foreach(op; func.ops)
            {
                auto type = op.operation.type;
                assert(type > TokenType.CODE_START && type < TokenType.CODE_END, format("Invalid opcode: %s", type));

                auto code = cast(Opcode)(type - TokenType.CODE_START);
                auto info = this._opcodes[code];

                this.write(cast(ubyte)code);

                enforce(op.parameters.length == info.params.length, 
                    new CompileException(
                        format("Expected %s parameters for %s, but only got %s", 
                                info.params.length, type, op.parameters.length)
                        ));
                foreach(i, param; info.params)
                {
                    auto given = op.parameters[i];

                    enforce(
                            (given.type == NodeType.String && param == OpcodeInfo.Param.String)
                         || (given.type == NodeType.Number && ((param & 0x00FF) >= OpcodeInfo.Param.Int8 && (param & 0x00FF) <= OpcodeInfo.Param.Int32)),
                            new CompileException(format("For opcode %s, expected a %s as the %sst/nd/th opcode, but got %s", type, param, i, given.type))
                        );

                    switch(given.type)
                    {
                        case NodeType.String:
                            auto x = cast(StringNode)given;
                            this.write(this.makeStringTableEntry(x));
                            break;

                        case NodeType.Number:
                            auto x = cast(NumberNode)given;
                            if(param & OpcodeInfo.Param.Unsigned)
                                this.writeNumberParameter!false(x.token.text, param);
                            else
                                this.writeNumberParameter!true(x.token.text, param);
                            break;

                        default: assert(0);
                    }
                }
            }
        }

        /// Returns:
        ///     The index of the string
        uint makeStringTableEntry(StringNode node)
        {
            foreach(i, str; this._strings)
                if(str == node.token.text)
                    return i;

            this._strings ~= node.token.text;
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
                    Opcode.PUSH_STRING:             OpcodeInfo([String]),
                    Opcode.PUSH_INT32:              OpcodeInfo([Int32]),
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
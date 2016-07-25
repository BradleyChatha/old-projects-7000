module jasm.compiler;

private
{
    import std.array     : appender, Appender;
    import std.bitmanip;
    import std.exception : enforce;

    import jasm.ast, jasm.opcodes, jasm.lexer;
}

ubyte[] compileJasm(NamespaceNode[] namespaces)
{
    return Compiler().compile(namespaces);
}

/++
 + This struct is responsible for compiling a JEXE
 + ++/
struct Compiler
{
    /++
     + Number parameters for an opcode will need to be a certain size, so this enum is used to represent their sizes.
     + ++/
    private enum NumType
    {
        None,
        Int8,
        Int16,
        Int32,
        UInt8,
        UInt16,
        UInt32
    }
    
    /++
     + Contains some extra information about an opcode, used for compiling.
     + ++/
    private struct OpcodeInfo
    {
        /// What the types of it's params are
        NodeType[]   params;
        
        /// What the types of it's number parameters are
        NumType[]    numTypes;
    }

    public static
    {
        alias               Append          = Appender!(ubyte[]);
        immutable(ushort)   formatVersion   = 0x0001;
        immutable(char[4])  fileHeader      = ['J', 'E', 'X', 'E'];
    }

    private
    {
        static OpcodeInfo[TokenType] opcodeParams = null;

        Append          output;
        size_t[string]  funcPosMap;
        bool            entryPoint;

        void setupParams()
        {
            if(Compiler.opcodeParams !is null)
                return;

            Compiler.opcodeParams = 
            [
                TokenType.CODE_PUSH_STRING:             OpcodeInfo([NodeType.String]),

                TokenType.CODE_PUSH_INT_32:             OpcodeInfo([NodeType.Number],
                                                                   [NumType.Int32]),

                TokenType.CODE_STORE_LOCAL:             OpcodeInfo([NodeType.Number],
                                                                   [NumType.UInt8]),

                TokenType.CODE_DEBUG_LOCALS:            OpcodeInfo([])
            ];
        }

        auto numParamToBytes(NumType T)(NumberNode param)
        {
            import std.conv   : to;
            import std.format : format;

            auto num = param.token.text.to!long;

            // First, make sure it follows the rules of being unsigned.
            enum unsigned = (T >= NumType.UInt8);
            static if(unsigned)
                enforce(num >= 0, new CompilerException(format("Expected an unsigned number, got '%s'", num), param.token.info));

            // Next, make sure it's in the correct range.
            ulong max;
            long  min;

            static if(T == NumType.Int8)
            {
                max = byte.max;
                min = byte.min;
            }
            else static if(T == NumType.Int16)
            {
                max = short.max;
                min = short.min;
            }
            else static if(T == NumType.Int32)
            {
                max = int.max;
                min = int.min;
            }
            else static if(T == NumType.UInt8)
            {
                max = ubyte.max;
                min = ubyte.min;
            }
            else static if(T == NumType.UInt16)
            {
                max = ushort.max;
                min = ushort.min;
            }
            else static if(T == NumType.UInt32)
            {
                max = uint.max;
                min = uint.min;
            }

            enforce(num >= min && num <= max, new CompilerException(format("Number is out of range: min = %s, max = %s, got = %s", min, max, num), param.token.info));

            // And then finally, turn it into bytes.
            static if(T == NumType.Int8 || T == NumType.UInt8)
                return (cast(ubyte)num).toBytes;
            else static if(T == NumType.Int16 || T == NumType.UInt16)
                return (cast(ushort)num).toBytes;
            else static if(T == NumType.Int32 || T == NumType.UInt32)
                return (cast(uint)num).toBytes;
            else
                static assert(false);
        }
    }

    /++
     + 
     + ++/
    ubyte[] compile(NamespaceNode[] namespaces)
    {
        assert(this.funcPosMap.length == 0, "This is a one-use struct");
        this.setupParams();

        this.writeHeader();
        this.writeNamespaceTable(namespaces);
        this.writeFunctions(namespaces);
        
        return output.data;
    }

    /++
     + [Header]
     + Writes out the JEXE's header.
     + ++/
    void writeHeader()
    {
        output.put(cast(ubyte[])fileHeader);
        output.put(formatVersion.toBytes[]);
        output.put(cast(ubyte)0x00);
    }

    /++
     + [String8/String16/etc.]
     + Writes a string with a length-prefix to the file.
     + ++/
    void writeString(T)(string data)
    {
        import std.format;
        enforce(data.length <= T.max, new Exception(format("The value of the String%s is too large: %s", T.sizeof * 8, data)));

        output.put((cast(T)data.length).toBytes[]);
        output.put(cast(immutable(ubyte)[])data);
    }
    alias writeString8  = writeString!ubyte;
    alias writeString16 = writeString!ushort;

    /++
     + [FuncDef[]]
     + Writes out the table of function definitions for a class.
     + ++/
    void writeFunctionTable(ClassNode node)
    {
        output.put((cast(uint)node.functions.length).toBytes[]);
        foreach(func; node.functions)
            this.funcPosMap[func.fullName]  = this.writeFunctionDefinition(func);
    }

    /++
     + [FuncDef]
     + Writes a function definition out.
     + 
     + Returns:
     +  The position to where the function pointer can be written to.
     + ++/
    size_t writeFunctionDefinition(FunctionNode func)
    {
        import std.algorithm : canFind;

        this.writeString16(func.signature);
        this.writeString16(func.locals.asList);

        // Figure out the flags
        ubyte flags = 0;
        foreach(attr; func.attributes)
        {
            switch(attr.token.text)
            {
                case "Static":
                    flags |= FuncFlags.IsStatic;
                    break;

                case "EntryPoint":
                    enforce(!this.entryPoint, new ASTException("There may only be one function marked as the entry point.", attr.token.info));
                    flags          |= FuncFlags.IsEntry;
                    this.entryPoint = true;
                    break;
                    
                default:
                    throw new ASTException("Unknown function attribute: " ~ attr.token.text, attr.token.info);
            }
        }

        // Force the function to be marked static
        if(func.parent.attributes.canFind!((a) => a.token.text == "Static"))
            flags |= FuncFlags.IsStatic;
            
        output.put(flags);

        // Reserve space for the pointer
        auto pos = output.data.length;
        output.put(0.toBytes[]);

        return pos;
    }

    /++
     + [ClassDef[]]
     + Writes out a table of class definitions.
     + ++/
    void writeClassTable(NamespaceNode node)
    {
        output.put((cast(uint)node.classes.length).toBytes[]);
        foreach(cls; node.classes)
            this.writeClassDefinition(cls);
    }

    /++
     + [ClassDef]
     + Writes out the definition for the class, as well as all of it's functions' definitions.
     + ++/
    void writeClassDefinition(ClassNode node)
    {
        this.writeString8(node.name);

        ubyte flags = 0;
        foreach(attr; node.attributes)
        {
            switch(attr.token.text)
            {
                case "Static":
                    flags |= ClassFlags.IsStatic;
                    break;

                default:
                    throw new ASTException("Unknown class attribute: " ~ attr.token.text, attr.token.info);
            }
        }
        output.put(flags);

        this.writeFunctionTable(node);
    }

    /++
     + [NamespaceDef[]]
     + Writes out a tbale of namespace definitions
     + ++/
    void writeNamespaceTable(NamespaceNode[] nodes)
    {
        output.put((cast(uint)nodes.length).toBytes[]);
        foreach(ns; nodes)
            this.writeNamespaceDefinition(ns);
    }

    /++
     + [NamespaceDef]
     + Writes out the definition for the namespace, as well as all of it's classes
     + ++/
    void writeNamespaceDefinition(NamespaceNode node)
    {
        this.writeString8(node.fullName);
        this.writeClassTable(node);
    }

    /++
     + [Opcodes[]]
     + 
     + Writes out all of the function's opcodes, and sets their pointers in their definitions.
     + ++/
    void writeFunctions(NamespaceNode[] namespaces)
    {
        uint length  = output.data.length;
        auto firstOp = output.data.length + length.sizeof;

        output.put(length.toBytes[]);
        foreach(ns; namespaces)
        {
            foreach(cls; ns.classes)
            {
                foreach(func; cls.functions)
                {
                    auto start = (output.data.length - firstOp);
                    this.writeFunctionOperations(func);

                    auto pos = funcPosMap[func.fullName];
                    output.data[pos..pos + uint.sizeof] = start.toBytes[];
                }
            }
        }

        uint size = (output.data.length - firstOp);
        output.data[length..length+length.sizeof] = size.toBytes[];
    }

    /++
     + [Opcodes]
     + 
     + 
     + ++/
    void writeFunctionOperations(FunctionNode func)
    {
        import std.format : format;

        foreach(op; func.ops)
        {
            auto wanted = opcodeParams[op.operation.type];
            output.put(cast(ubyte)op.operation.type.toOpcode);

            enforce(
                op.parameters.length == wanted.params.length, 
                new CompilerException(format("For opcode '%s', expected %s operands, but got %s operands.", 
                        op.operation.type, wanted.params.length, op.parameters.length), 
                    op.operation.info)
                );
            foreach(i, param; op.parameters)
            {
                enforce(
                    param.type == wanted.params[i], 
                    new CompilerException(format("For opcode '%s', expected operand %s to be of type %s", 
                        op.operation.type, i, wanted.params[i]),
                    op.operation.info)
                    );

                switch(param.type) with(NodeType)
                {
                    case String:
                        auto p = cast(StringNode)param;
                        this.writeString8(p.token.text);
                        break;

                    case Number:
                        auto    p = cast(NumberNode)param;
                        ubyte[] data;

                        switch(wanted.numTypes[i]) with(NumType)
                        {
                            case Int8:      data = this.numParamToBytes!Int8(p)[];      break;
                            case Int16:     data = this.numParamToBytes!Int16(p)[];     break;
                            case Int32:     data = this.numParamToBytes!Int32(p)[];     break;
                            case UInt8:     data = this.numParamToBytes!UInt8(p)[];     break;
                            case UInt16:    data = this.numParamToBytes!UInt16(p)[];    break;
                            case UInt32:    data = this.numParamToBytes!UInt32(p)[];    break;

                            default:
                                assert(false);
                        }

                        output.put(data);
                        break;

                    default:
                        assert(false, "Unhandled type");
                }
            }
        }
    }
}

package
{
    /++
     + See nativeToBigEndian.
     + 
     + This just makes sure it's the same endianness as the system's
     + ++/
    auto toBytes(T)(T thing)
    {
        version(BigEndian)
            return nativeToBigEndian!T(thing);
        else
            return nativeToLittleEndian!T(thing);
    }
}

/// The exception that is thrown by the copmiler.
class CompilerException : Exception
{
    public
    {
        /++
         + Creates a new CompilerException.
         + 
         + Parameters:
         +  msg = The error message.
         +  info = The debug info for where things went wrong.
         + ++/
        @safe
        this(string msg, TokenDebugInfo info, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
        {
            super(format("[%s] on line %s column %s: '%s'", info.file, info.line, info.column, msg), file, line, next);
        }
    }
}
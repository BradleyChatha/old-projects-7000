module jasm.compiler;

private
{
    import std.array     : appender, Appender;
    import std.bitmanip;
    import std.exception : enforce;

    import jasm.ast, jasm.opcodes;
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
    public static
    {
        alias               Append          = Appender!(ubyte[]);
        immutable(ushort)   formatVersion   = 0x0001;
        immutable(char[4])  fileHeader      = ['J', 'E', 'X', 'E'];
    }

    private
    {
        Append          output;
        size_t[string]  funcPosMap;
        bool            entryPoint;
    }

    /++
     + 
     + ++/
    ubyte[] compile(NamespaceNode[] namespaces)
    {
        assert(this.funcPosMap.length == 0, "This is a one-use struct");

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
        foreach(op; func.ops)
        {
            output.put(cast(ubyte)op.operation.type.toOpcode);

            foreach(param; op.parameters)
            {
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
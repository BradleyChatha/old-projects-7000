module sasm.parser.ast;

import sasm.parser.tabwriter;
import pegged.grammar;

public import std.typecons : Flag, Yes, No;

///
abstract class Node
{
    ///
    enum Type : ubyte
    {
        Value_I32               = 0x01,
        Value_U32               = 0x00,
        Value_U8                = 0x03,
        Value_I8                = 0x04,
        Value_Float32           = 0x02,
        Value_String            = 0x05,
        Value_Label             = 0xD0, // Note: The type descriptor for 'Label' is never actually written out, it shares the same as I32.
        Value_Variable_Ptr      = 0xD1, // Note: 'Variable' is actually an instruction, not a type, so the value in this enum does nothing.
        Value_Variable_Stack    = 0xD2, // Note: ^^^^

        // DUMMY VALUE
        Dummy = 0xE0,

        Mneumonic,
        Code,
        Declaration
    }

    private
    {
        Type _type;
    }

    public
    {
        ///
        @safe @nogc
        this(Type type) nothrow
        {
            this._type = type;
        }

        ///
        @safe
        abstract void writeDebugString(TabWriter writer);

        ///
        @safe
        override string toString()
        {
            auto writer = new TabWriter();
            this.writeDebugString(writer);

            return writer.text();
        }

        /++
         + Returns:
         +  The node's `Type`.
         + ++/
        @property @safe @nogc
        const(Type) type() nothrow pure const
        {
            return this._type;
        }
    }
}

/// Holds a value.
/// Can be seen in the grammar as "Sasm.Value"
class NodeValue : Node
{
    import std.variant : Algebraic;

    ///
    alias Value = Algebraic!(int, string, float, uint, ubyte, byte);

    private
    {
        Value _value;
    }

    public
    {

        /// Ctor for most other types.
        @trusted
        this(T)(T value)
        if(!is(T == string) && NodeValue.Value.allowed!T)
        {
                 static if(is(T == int))    alias nType = Node.Type.Value_I32;
            else static if(is(T == uint))   alias nType = Node.Type.Value_U32;
            else static if(is(T == byte))   alias nType = Node.Type.Value_I8;
            else static if(is(T == ubyte))  alias nType = Node.Type.Value_U8;
            else static if(is(T == float))  alias nType = Node.Type.Value_Float32;
            else static assert(false, T.stringof);

            super(nType);
            this._value = value;
        }

        /// Ctor for string values.
        @trusted @nogc
        this(string str,                                Flag!"isLabel" label         = No.isLabel, 
            Flag!"isVariable" variable = No.isVariable, Flag!"isStackVariable" stack = No.isStackVariable) nothrow
        {
            with(Node.Type)
            {
                super((label) ? Value_Label 
                              : (variable) ? ((stack) ? Value_Variable_Stack : Value_Variable_Ptr)
                                           : Value_String);
            }
            this._value = str;
        }

        @trusted
        override void writeDebugString(TabWriter writer)
        {
            import std.format : format;
            writer.write(format("[Value] <Type:%s> <Value:%s>", this.type, this._value));
        }

        /++
         + Notes:
         +  This is essentially a call to `VariantN.get`.
         + 
         + Returns:
         +  The `Value` of the value.
         + ++/
        @property @trusted
        inout(T) value(T)() inout
        {
            return this._value.get!T;
        }
    }
}

///
class NodeMneumonic : Node
{
    ///
    enum Instruction
    {
        ///
        Nop   = 0x00,
        
        ///
        Print = 0x02,

        ///
        Jump  = 0x03
    }

    public
    {
        /// The `Instruction` being represented.
        Instruction opcode;

        /// Which labels point to this mneumonic.
        string[]    labels;

        /// The operands to this instruction.
        NodeValue[] operands;
    }

    public
    {
        ///
        @safe @nogc
        this(Instruction opcode, NodeValue[] operands = null, string[] labels = null) nothrow
        {
            this.opcode     = opcode;
            this.operands   = operands;
            this.labels     = labels;

            super(Node.Type.Mneumonic);
        }

        @trusted
        override void writeDebugString(TabWriter writer)
        {
            import std.format    : format;
            import std.algorithm : each;

            writer.write(format("[Mneumonic] <Opcode:%s> <Labels:%s>", this.opcode, this.labels));
            writer.write("[Values]");
            writer.entab();
            this.operands.each!(o => o.writeDebugString(writer));
            writer.detab();
        }
    }
}

///
class NodeCode : Node
{
    public
    {
        NodeMneumonic[]   opcodes;
        NodeDeclaration[] variables;
    }

    public
    {
        ///
        @safe @nogc
        this() nothrow
        {
            super(Node.Type.Code);
        }

        @safe
        override void writeDebugString(TabWriter writer)
        {
            import std.algorithm : each;

            writer.write("[Code]");

            writer.write("[Variables]");
            writer.entab();
            this.variables.each!(v => v.writeDebugString(writer));
            writer.detab();

            writer.write("[Mneumonics]");
            writer.entab();
            this.opcodes.each!(o => o.writeDebugString(writer));
            writer.detab();
        }
    }
}

///
class NodeDeclaration : Node
{
    public
    {
        string    name;
        NodeValue value;
    }

    public
    {
        ///
        @safe @nogc
        this(string name, NodeValue value = null) nothrow
        {
            this.name  = name;
            this.value = value;
            super(Node.Type.Declaration);
        }

        ///
        @safe
        override void writeDebugString(TabWriter writer)
        {
            writer.write("[Declaration] <Name:" ~ this.name ~ ">");
            writer.entab();
            this.value.writeDebugString(writer);
            writer.detab();
        }
    }
}

private struct ParseInfo
{
    string[] labelStack;
}

///
@safe
NodeCode treeToAst(ParseTree tree)
{
    import std.format : format;

    if(tree.name == "Sasm")
        tree = tree.children[0];

    tree.enforceTreeName("Sasm.Code");
    auto code = new NodeCode();
    auto info = ParseInfo();

    foreach(child; tree.children)
    {
        switch(child.name)
        {
            case "Sasm.Label":      child.parseLabel(info);                         break;
            case "Sasm.Mneumonic":  code.opcodes    ~= child.parseMneumonic(info);  break;
            case "Sasm.Variable":   code.variables  ~= child.parseDeclaration();    break;

            default:
                throw new Exception(format("Invalid tree name: '%s'", child.name));
        }
    }

    return code;
}

@safe
private void parseLabel(ParseTree tree, ref ParseInfo info)
{
    tree.enforceTreeName("Sasm.Label");
    tree.enforceTreeMatchCount(1);

    info.labelStack ~= tree.matches[0];
}

@safe
private NodeMneumonic parseMneumonic(ParseTree tree, ref ParseInfo info)
{
    tree.enforceTreeName("Sasm.Mneumonic");
    assert(tree.children.length == 1);

    tree = tree.children[0];

    // Create the node
    auto code = new NodeMneumonic(tree.name.nameToOpcode);

    // Assign the labels to it
    code.labels = info.labelStack.dup;
    info.labelStack.length = 0;

    // Then parse it's operands
    foreach(child; tree.children)
        code.operands ~= child.parseValue();

    return code;
}

@safe
private NodeDeclaration parseDeclaration(ParseTree tree)
{
    tree.enforceTreeName("Sasm.Variable");
    assert(tree.children.length == 1);

    auto name = tree.matches[0];
    tree      = tree.children[0];
    tree.enforceTreeName("Sasm.Value");

    auto value = tree.parseValue();

    return new NodeDeclaration(name, value);
}

@safe
private NodeValue parseValue(ParseTree tree)
{
    import std.conv : to;

    if(tree.name == "Sasm.Value")
        tree = tree.children[0];
        
    auto match = tree.matches[0];

    switch(tree.name)
    {
        case "Sasm.Val_Variable_Stack":     return new NodeValue(match, No.isLabel, Yes.isVariable, Yes.isStackVariable);
        case "Sasm.Val_Variable_Ptr":       return new NodeValue(match, No.isLabel, Yes.isVariable, No.isStackVariable);
        case "Sasm.Val_Label":              return new NodeValue(match, Yes.isLabel);
        case "Sasm.String":                 return new NodeValue(match.escapeString);
        case "Sasm.Int32":                  return new NodeValue(match.to!int);
        case "Sasm.Float32":                return new NodeValue(match.to!float);
        case "Sasm.UInt32":                 return new NodeValue(match.to!uint);
        case "Sasm.Int8":                   return new NodeValue(match.to!byte);
        case "Sasm.UInt8":                  return new NodeValue(match.to!ubyte);

        default:
            throw new Exception(tree.name);
    }
}

@trusted
private string escapeString(string s)
{
    import std.exception : assumeUnique;

    char[] buffer;

    bool escape = false;
    foreach(char c; s)
    {
        if(c == '\\')
        {
            if(escape)
            {
                buffer ~= '\\';
                escape = false;
                continue;
            }
            else
            {
                escape = true;
                continue;
            }
        }

        if(escape)
        {
            escape = false;

            switch(c)
            {
                case 'n': buffer ~= '\n'; break;
                case 'r': buffer ~= '\r'; break;
                case '"': buffer ~= '"';  break;

                default: throw new Exception([c]);
            }
        }
        else
            buffer ~= c;
    }

    return buffer.assumeUnique;
}

// "Mne_Print": Instruction.Print, etc.
private static NodeMneumonic.Instruction[string] _opcodeStrings;
@safe
private NodeMneumonic.Instruction nameToOpcode(string name)
{
    import std.exception : enforce;

    with(NodeMneumonic.Instruction)
    {
        if(_opcodeStrings is null)
        {
            _opcodeStrings = 
            [
                "Sasm.Mne_Print": Print,
                "Sasm.Mne_Nop":   Nop,
                "Sasm.Mne_Jump":  Jump
            ];
        }
    }

    auto ptr = (name in _opcodeStrings);
    enforce(ptr !is null, name);

    return *ptr;
}

@trusted
private void enforceTreeName(ParseTree tree, string name)
{
    import std.exception : enforce;
    import std.format    : format;

    enforce(tree.name == name, format("Expected tree to have the name of '%s', not '%s'.", name, tree.name));
}

@trusted
private void enforceTreeMatchCount(ParseTree tree, size_t count)
{
    import std.exception : enforce;
    import std.format    : format;

    enforce(tree.matches.length == count, format("Expected tree called '%s' to have %s matches, but it has %s matches. Matches = %s",
                                                 tree.name, count, tree.matches.length, tree.matches));
}
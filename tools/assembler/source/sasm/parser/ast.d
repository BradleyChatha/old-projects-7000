module sasm.parser.ast;

import sasm.parser.tabwriter;
import pegged.grammar;

///
abstract class Node
{
    ///
    enum Type
    {
        Value_String,
        Value_I32,

        Mneumonic,
        Code
    }

    private
    {
        Type _type;
    }

    public
    {
        ///
        this(Type type)
        {
            this._type = type;
        }

        ///
        abstract void writeDebugString(TabWriter writer);

        ///
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
    alias Value = Algebraic!(int, string);

    private
    {
        Value _value;
    }

    public
    {
        /// Ctor for Int32 values.
        this(int i32)
        {
            super(Node.Type.Value_I32);
            this._value = i32;
        }

        /// Ctor for string values.
        this(string str)
        {
            super(Node.Type.Value_String);
            this._value = str;
        }

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
        @property
        inout(T) value(T)() inout
        {
            return this._value.get!T;
        }
    }
}

///
class NodeMneumonic : Node
{
    enum Instruction
    {
        Print = 0x01
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
        this(Instruction opcode, NodeValue[] operands = null, string[] labels = null)
        {
            this.opcode     = opcode;
            this.operands   = operands;
            this.labels     = labels;

            super(Node.Type.Mneumonic);
        }

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
        NodeMneumonic[] opcodes;
    }

    public
    {
        ///
        this()
        {
            super(Node.Type.Code);
        }

        override void writeDebugString(TabWriter writer)
        {
            import std.algorithm : each;

            writer.write("[Code]");
            writer.write("[Mneumonics]");
            writer.entab();
            this.opcodes.each!(o => o.writeDebugString(writer));
            writer.detab();
        }
    }
}

private struct ParseInfo
{
    string[] labelStack;
}

///
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
            case "Sasm.Label":      child.parseLabel(info);                     break;
            case "Sasm.Mneumonic":  code.opcodes ~= child.parseMneumonic(info); break;

            default:
                throw new Exception(format("Invalid tree name: '%s'", child.name));
        }
    }

    return code;
}

private void parseLabel(ParseTree tree, ref ParseInfo info)
{
    tree.enforceTreeName("Sasm.Label");
    tree.enforceTreeMatchCount(1);

    info.labelStack ~= tree.matches[0];
}

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

private NodeValue parseValue(ParseTree tree)
{
    import std.conv : to;

    tree.enforceTreeName("Sasm.Value");
    assert(tree.children.length == 1);

    tree       = tree.children[0];
    auto match = tree.matches[0];

    switch(tree.name)
    {
        case "Sasm.String": return new NodeValue(match);
        case "Sasm.Int32":  return new NodeValue(match.to!int);

        default:
            throw new Exception(tree.name);
    }
}

// "Mne_Print": Instruction.Print, etc.
private static NodeMneumonic.Instruction[string] _opcodeStrings;
private NodeMneumonic.Instruction nameToOpcode(string name)
{
    import std.exception : enforce;

    with(NodeMneumonic.Instruction)
    {
        if(_opcodeStrings is null)
        {
            _opcodeStrings = 
            [
                "Sasm.Mne_Print": Print
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
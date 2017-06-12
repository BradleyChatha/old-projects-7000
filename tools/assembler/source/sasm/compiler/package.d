module sasm.compiler;

import sasm.parser.ast;

///
class Compiler
{
    private
    {
        struct Label
        {
            string name;
            uint   offset;
        }

        NodeCode _code;
        ubyte[]  _binary;
        uint     _index;

        Label[string] _labels;

        uint _pointerTableLengthPointer;
        uint   _pointerTableLength;
        uint _functionTableLengthPointer;
        uint _bodyPointer;
    }

    public
    {
        ///
        this(string sasm)
        {
            import std.stdio           : writefln;
            import sasm.parser.grammar : parseSasm;
            this._code = sasm.parseSasm.treeToAst();

            debug
            {
                writefln("Parsing the Sasm code:\n%s", sasm);
                writefln("\n\nParseTree:\n%s", sasm.parseSasm);
                writefln("\n\nAST:\n%s", this._code);
            }
        }

        ///
        ubyte[] compile()
        {
            if(this._binary is null)
                this.doCompile();
            
            return this._binary;
        }
    }

    private
    {
        void doCompile()
        {
            this.writeHeader();
            this.writePointerTable();
            this.writeFunctionTable();
            this.writeBody();
        }

        void writeHeader()
        {
            this.write(cast(ubyte[])['S', 'V', 'M']);

            this._pointerTableLengthPointer = this._index;
            this.writeBE!int(0); // Pointer table length

            this._functionTableLengthPointer = this._index;
            this.writeBE!int(0); // Function table length
        }

        void writePointerTable()
        {
            // Write the pointer table itself
            // TODO

            // Write the size of the pointer table (INCORRECT)
            auto current = this._index;
            uint size    = cast(uint)((current - this._functionTableLengthPointer) - int.sizeof);
            assert(size <= current, "overflow");

            this._pointerTableLength = size;
            this._index  = this._pointerTableLengthPointer;
            this.writeBE!int(size);
            this._index  = current;
        }

        void writeFunctionTable()
        {
            // Write the function table itself

            // Write the size of the function table (DOESN'T EVEN GET WRITTEN (in the right place))
            auto current = this._index;
            uint size    = cast(uint)(current - (this._functionTableLengthPointer + int.sizeof + this._pointerTableLength));
            assert(size <= current, "overflow/incorrect maths");

            this._index  = this._functionTableLengthPointer;
            this.writeBE!int(size);
            this._index  = current;
        }

        void writeBody()
        {
            this._bodyPointer = this._index;

            foreach(child; this._code.opcodes)
                this.writeOpcode(child);
        }

        void writeOpcode(NodeMneumonic node)
        {
            // Assign labels
            foreach(label; node.labels)
            {
                if((label in this._labels) !is null)
                    throw new Exception(label); // TODO: Improve message.

                this._labels[label] = Label(label, this._index - this._bodyPointer);
            }

            // Write the opcode
            this.write(cast(ubyte)node.opcode);

            // Write the operands.
            foreach(operand; node.operands)
            {
                switch(operand.type) with(Node.Type)
                {
                    case Value_I32: 
                        this.write(0x03);
                        this.writeBE!int(operand.value!int);
                        break;

                    case Value_String:
                        auto str = operand.value!string;

                        this.write(0x05);
                        this.write(cast(ubyte)str.length); // TODO: Size check.
                        this.write(cast(immutable(ubyte[]))str);
                        break;

                    case Value_Float32:
                        this.write(0x04);
                        this.writeBE!float(operand.value!float);
                        break;

                    case Value_Label:
                        auto name = operand.value!string;
                        auto ptr  = (name in this._labels);

                        if(ptr is null)
                            throw new Exception(name); // TODO

                        // Special case: Jump doesn't expect this
                        if(node.opcode != NodeMneumonic.Instruction.Jump)
                            this.write(0x03);

                        this.writeBE!int(ptr.offset);
                        break;

                    default:
                        throw new Exception("TODO");
                }
            }
        }

        // Helper functions

        void write(ubyte value)
        {
            this.write([value]);
        }

        void write(const ubyte[] value)
        {
            auto end = cast(uint)(this._index + value.length);

            if(this._binary.length < end)
                this._binary.length = end;

            this._binary[this._index..end] = value[];
            this._index = end;
        }

        void writeBE(T)(T value)
        {
            import std.bitmanip : nativeToBigEndian;
            this.write(nativeToBigEndian(value)[]);
        }
    }
}
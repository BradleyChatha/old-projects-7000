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
            size_t offset;
        }

        NodeCode _code;
        ubyte[]  _binary;
        size_t   _index;

        Label[string] _labels;

        size_t _pointerTableLengthPointer;
        uint   _pointerTableLength;
        size_t _functionTableLengthPointer;
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
            auto size    = (current - this._functionTableLengthPointer) - int.sizeof;
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
            auto size    = (current - (this._functionTableLengthPointer + int.sizeof + this._pointerTableLength));
            assert(size <= current, "overflow/incorrect maths");

            this._index  = this._functionTableLengthPointer;
            this.writeBE!int(size);
            this._index  = current;
        }

        void writeBody()
        {
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

                this._labels[label] = Label(label, this._index);
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

                        // Code tis very sloppy though.
                        this.write(0x05);
                        this.write(cast(ubyte)str.length); // TODO: Size check.
                        this.write(cast(immutable(ubyte[]))str);
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
            auto end = this._index + value.length;

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
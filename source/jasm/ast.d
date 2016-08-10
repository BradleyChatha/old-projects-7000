module jasm.ast;

private
{
    import std.array;
    import std.exception : enforce;
    import std.format    : format;
    import std.range     : ElementType, isInputRange;

    import jasm.lexer;
}

version(none):
/++
 + A `Node`'s type.
 + ++/
enum NodeType
{
    /// This `Node` describes an operation
    /// 
    /// e.g. "debug.locals"
    Opcode,

    /// This `Node` contains a string value.
    String,

    /// This `Node` contains a number value.
    Number,

    /// This `Node` contains a varaible's type
    /// 
    /// e.g. "int32"
    VariableType,

    /// This `Node` contains a list of `VariableType`s
    TypeList,

    /// This `Node` contains an attribute.
    /// 
    /// e.g. "[EntryPoint]"
    Attribute,

    /// This `Node` contains a function.
    Function,

    /// This `Node` contains a class.
    Class,

    /// This `Node` contains a namespace.
    Namespace,

    /// This `Node` contains information about an entire file(or an entire piece of code, since they're treated as the same thing)
    File,

    /// This `Node` contains a namespace's name, which determines what files get imported.
    Import,
}

/++
 + The base class for all nodes.
 + ++/
abstract class Node
{
    private
    {
        /// The node's type.
        NodeType    _type;
    }

    public
    {
        /++
         + Params:
         +  type = The type of the node.
         + ++/
        @safe @nogc
        this(NodeType type) nothrow
        {
            this._type = type;
        }

        /++
         + Returns the Node's type.
         + ++/
        @property @safe @nogc
        NodeType type() nothrow pure const
        {
            return this._type;
        }
    }
}

/++
 + A node containing tokens about an Opcode.
 + ++/
class OpcodeNode : Node
{
    private
    {
        Token   _op;
        Node[]  _params;
    }

    public
    {
        /++ 
         + Throws:
         +  `ASTException` if either $(D operation) or any of the $(D parameters) are incorrect types.
         + 
         + Params:
         +  operation  = The token holding the operation.
         +  parameters = The tokens being used as parameters.
         + ++/
        @safe
        this(Token operation, Token[] parameters)
        {
            import std.algorithm : reduce;

            enforce(operation.type > TokenType.CODE_START && operation.type < TokenType.CODE_END,
                new ASTException(format("Unknown operation: %s", operation.text), operation.info));

            this._op = operation;
            while(!parameters.empty)
                this._params ~= parameters.nextValueNode;
            
            super(NodeType.Opcode);
        }

        @property @safe @nogc
        nothrow const pure
        {
            /++
             + Returns the token representing the operation.
             + ++/
            Token operation()
            {
                return this._op;
            }

            /++
             + Returns the nodes that are to be used as parameters.
             + ++/
            const(Node[]) parameters()
            {
                return this._params;
            }
        }
    }
}

/++
 + A simple, and generic class for representing a basic node that simply holds a token.
 + 
 + Params:
 +  TType = The type of the token that should be passed.
 +  Type  = The Node type of this node.
 + ++/
class ValueNode(TokenType TType, NodeType Type) : Node
{
    private
    {
        Token   _tok;
    }

    public
    {
        /++
         + Throws:
         +  `ASTException` if $(D tok)'s type is not the same as $(D TType).
         + 
         + Params:
         +  tok = The value of the node.
         + ++/
        @safe
        this(Token tok)
        {
            enforce(tok.type == TType, new ASTException(format("Expected Token of type %s, got %s", TType, tok.type), tok.info));
            this._tok = tok;

            super(Type);
        }

        /++
         + The token representing the value of this node.
         + ++/
        @property @safe @nogc
        Token token() nothrow pure const
        {
            return this._tok;
        }
    }
}
alias StringNode    = ValueNode!(TokenType.UNIQ_STRING,        NodeType.String);
alias NumberNode    = ValueNode!(TokenType.UNIQ_NUMBER,        NodeType.Number);
alias TypeNode      = ValueNode!(TokenType.UNIQ_IDENTIFIER,    NodeType.VariableType);
alias AttributeNode = ValueNode!(TokenType.UNIQ_IDENTIFIER,    NodeType.Attribute);

/++
 + The node that contains a list of `TypeNode`s
 + ++/
class TypeListNode : Node
{
    private
    {
        TypeNode[]  _types;
    }

    public
    {
        /++
         + Assertions:
         +  $(D types) should not be null.
         + 
         + Params:
         +  types = The list of types.
         + ++/
        @safe @nogc
        this(TypeNode[] types) nothrow
        {
            this._types = types;
            super(NodeType.TypeList);
        }

        /++
         + Returns the types of the function's local variables.
         + ++/
        @property @safe @nogc
        const(TypeNode[]) types() nothrow const pure
        {
            return this._types;
        }

        /++
         + Returns all of the types in the list, as a string.
         + ++/
        @property @safe
        string asList() nothrow
        {
            auto name = "";

            foreach(param; this.types)
                name ~= ("&" ~ param.token.text);

            return name;
        }
    }
}

/++
 + Contains a function, including the operations it should take.
 + ++/
class FunctionNode : Node
{
    private
    {
        string          _name;
        TypeNode        _retType;
        AttributeNode[] _attributes;
        OpcodeNode[]    _ops;
        TypeListNode    _locals;
        TypeListNode    _params;
        ClassNode       _class;
    }

    public
    {
        /++
         + Throws:
         +  `ASTException` if $(D name) is not an identifier.
         + 
         + Assertions:
         +  Some of the parameters should not be null.
         + 
         + Params:
         +  name        = The function's name.
         +  params      = The function's parameters.
         +  retType     = The return type of the function.
         +  attribtues  = The function's attributes.
         +  locals      = The function's local variables.
         +  ops         = The operations the function takes.
         + ++/
        @safe
        this(Token name, TypeListNode params, TypeNode retType, AttributeNode[] attributes, TypeListNode locals, OpcodeNode[] ops)
        {
            name.enforceToken(TokenType.UNIQ_IDENTIFIER, "an Identifier for a function's name");

            assert(params       !is null);
            assert(retType      !is null);
            assert(locals       !is null);

            this._name          = name.text;
            this._retType       = retType;
            this._ops           = ops;
            this._locals        = locals;
            this._params        = params;
            this._attributes    = attributes;

            super(NodeType.Function);
        }

        // TODO: Comments
        @property @safe @nogc
        nothrow pure
        {
            /++
             + Returns the name of the function.
             + ++/
            string name()
            {
                return this._name;
            }

            /++
             + Returns the type of the parameters of the function.
             + ++/
            TypeListNode params()
            {
                return this._params;
            }

            /++
             + Returns the type of the function's return value.
             + ++/
            TypeNode retType()
            {
                return this._retType;
            }

            /++
             + Returns the attributes attached to the function.
             + ++/
            AttributeNode[] attributes()
            {
                return this._attributes;
            }

            /++
             + Returns the type of function's local variables.
             + ++/
            TypeListNode locals()
            {
                return this._locals;
            }

            /++
             + Returns the opcodes of the function.
             + ++/
            OpcodeNode[] ops()
            {
                return this._ops;
            }

            /++
             + Returns the class that this function belongs to.
             + ++/
            ClassNode parent()
            {
                return this._class;
            }
        }

        /++
         + Returns the mangled signature of the function.
         + ++/
        @property @safe
        string signature() nothrow
        {
            auto name = this.name;

            name ~= this.params.asList;            
            name ~= ("$" ~ this.retType.token.text);

            return name;
        }

        /++
         + Returns the full name of the function, which includes the class.
         + ++/
        @property @safe
        string fullName() nothrow
        {
            assert(this._class !is null);
            return (this._class.fullName ~ "#" ~ this.signature);
        }
    }
}

/++
 + Contains a class.
 + ++/
class ClassNode : Node
{
    private
    {
        string              _name;
        FunctionNode[]      _functions;
        AttributeNode[]     _attributes;
        NamespaceNode       _namespace;
    }

    public
    {
        /++
         + Throws:
         +  `ASTException` if $(D name) is not an identifier.
         + 
         + Params:
         +  name        = The name of the class.
         +  attributes  = The attributes of the class.    
         + ++/
        @safe
        this(Token name, AttributeNode[] attributes)
        {
            name.enforceToken(TokenType.UNIQ_IDENTIFIER, "an Indentifier for a class' name");

            this._name       = name.text;
            this._attributes = attributes;
            super(NodeType.Class);
        }

        /++
         + Registers a function with the class.
         + 
         + Params:
         +  func = The function to register.
         + ++/
        @safe
        void registerFunction(FunctionNode func) nothrow
        {
            func._class      = this;
            this._functions ~= func;
        }

        @property @safe @nogc
        nothrow pure
        {
            /++
             + Returns the name of the class.
             + ++/
            string name()
            {
                return this._name;
            }

            /++
             + Returns all of the functions inside the class.
             + ++/
            FunctionNode[] functions()
            {
                return this._functions;
            }

            /++
             + Returns all of the attributes attached to the class.
             + ++/
            AttributeNode[] attributes()
            {
                return this._attributes;
            }
        }

        /++
         + Returns the full name of the class, which includes the namespace.
         + ++/
        @property @safe
        string fullName() nothrow
        {
            assert(this._namespace !is null);
            return (this._namespace.name.fullName ~ ":" ~ this.name);
        }
    }
}

/++
 + This helper struct is used to seperate, and recreate the names of a namespace.
 + ++/
struct NamespaceName
{
    private
    {
        string[] _segments;
    }

    public
    {
        /++
         + Params:
         +  nameTokens = The tokens that make up the name of the namespace.
         + ++/
        @safe
        this(Token[] nameTokens)
        {
            // Make sure the tokens are correct
            bool wantSeperator = false;
            foreach(tok; nameTokens)
            {
                if(!wantSeperator)
                {
                    tok.enforceToken(TokenType.UNIQ_IDENTIFIER, "an Identifier for a namespace");
                    this._segments ~= tok.text;
                    
                    wantSeperator = true;
                }
                else
                {
                    tok.enforceToken(TokenType.OP_NAMESPACE_SEPERATOR, "a '/' to seperate namespace segments");
                    wantSeperator = false;
                }
            }
            enforce(wantSeperator, new ASTException("Namespaces shouldn't end with a '/'", nameTokens[0].info));
        }

        /++
         + Returns the full name of the namespace.
         + ++/
        @property @safe
        string fullName() nothrow pure
        {
            return this._segments.join("/");
        }

        /++
         + Returns an array of all of the segments in the namespace's name.
         + ++/
        @property @safe @nogc
        string[] segments() nothrow pure
        {
            return this._segments;
        }
    }
}

/++
 + Contains a namespace.
 + ++/
class NamespaceNode : Node
{
    private
    {
        NamespaceName   _name;
        ClassNode[]     _classes;
    }

    public
    {
        /++
         + Throws:
         +  `ASTException` if the name is invalid.
         + 
         + Params:
         +  name = The name of the namespace.
         + ++/
        @safe
        this(NamespaceName name)
        {
            this._name = name;
            super(NodeType.Namespace);
        }

        /++
         + Registers a new class to the Namespace
         + 
         + Params:
         +  node = The node to register.
         + ++/
        @safe
        void registerClass(ClassNode node) nothrow
        {
            node._namespace = this;
            this._classes  ~= node;
        }

        @property @safe
        nothrow pure
        {
            /++
             + Returns the classes in the namespace.
             + ++/
            @nogc
            ClassNode[] classes()
            {
                return this._classes;
            }

            /++
             + Returns a helper struct to access the namespace's name.
             + ++/
            @nogc
            NamespaceName name()
            {
                return this._name;
            }
        }
    }
}

/++
 + This node contains a namespace's name, which will be used to import the namespace.
 + ++/
class ImportNode : Node
{
    private
    {
        NamespaceName _name;
    }

    public
    {
        /++
         + Params:
         +  name = The namespace's name.
         + ++/
        @safe @nogc
        this(NamespaceName name) nothrow
        {
            this._name = name;
            super(NodeType.Import);
        }

        /++
         + Params:
         +  name = The tokens making up the namespace's name.
         + ++/
        @safe
        this(Token[] nameTokens)
        {
            this._name = NamespaceName(nameTokens);
            super(NodeType.Import);
        }

        /++
         + Returns the name of the namespace to import.
         + ++/
        @property @safe @nogc
        NamespaceName name() nothrow pure
        {
            return this._name;
        }
    }
}

/++
 + This node is created from parsing an entire piece of code (Which probably comes from a file).
 + ++/
class FileNode : Node
{
    private
    {
        NamespaceNode _namespace;
        ImportNode[]  _imports;
    }

    public
    {
        /++
         + Creates a new FileNode, which represents everything about a piece of code..
         + 
         + Assertions:
         +  $(D namespace) must not be `null`.
         + 
         + Params:
         +  namespace = The namespace that the code adds to.
         + ++/
        @safe @nogc
        this(NamespaceNode namespace) nothrow
        {
            assert(namespace !is null);

            this._namespace = namespace;
            super(NodeType.File);
        }

        /++
         + Adds a namespace that is to be imported.
         + 
         + Params:
         +  name = The name of the namespace to import.
         + ++/
        @safe
        void addImport(NamespaceName name)
        {
            this._imports ~= new ImportNode(name);
            // TODO: MAke sure no namespace is repeated twice.
        }

        /++
         + Returns the node contaning most of the information about the code.
         + ++/
        @property @safe @nogc
        NamespaceNode namespace() nothrow pure
        {
            return this._namespace;
        }

        /++
         + Returns all of the namespaces this file imports.
         + ++/
        @property @safe @nogc
        ImportNode[] imports() nothrow pure
        {
            return this._imports;
        }
    }
}

/++
 + Determines if a token can be used a parameter to an operation.
 + 
 + Params:
 +  param = The token to check.
 + 
 + Returns:
 +  `true` if it's valid.
 +  `false` otherwise.
 + ++/
@safe @nogc
bool validOpParameter(Token param) nothrow pure
{
    return 
               param.type == TokenType.UNIQ_IDENTIFIER
            || param.type == TokenType.UNIQ_NUMBER
            || param.type == TokenType.UNIQ_STRING;
}

/++
 + Parses the entire piece of code.
 + 
 + Throws:
 +  `ASTException` if something is invalid.
 + 
 + Params:
 +  lex = The input range of tokens.
 + 
 + Returns:
 +  A `FileNode` containing all of the information about the code.
 + ++/
@safe
FileNode parseCode(R)(ref R lex)
{
    auto info = lex.front.info;
    lex.front.enforceToken(TokenType.KEY_NAMESPACE, ".namespace must be at the start of every piece of JASM code");
    lex.popFront;

    // Get the name of the namespace
    auto name = lex.nextNamespaceName;
    auto node = new FileNode(new NamespaceNode(name));

    // Read in all the stuff needed
    while(!lex.empty)
    {
        switch(lex.front.type) with(TokenType)
        {
            case KEY_CLASS:
                node.namespace.registerClass(lex.nextClass);
                break;

            case KEY_IMPORT_NAMESPACE:
                lex.popFront();
                name = lex.nextNamespaceName();

                node.addImport(name);
                break;

            default: throw new ASTException(format("Unexpected token %s", lex.front), lex.front.info);
        }
    }

    return node;
}
// For ease of testing, this class is tested in nextFunction's unittest

/++
 + Reads in the next name of a namespace.
 + 
 + Throws:
 +  `ASTException` if something is invalid.
 + 
 + Params:
 +  lex = The input range of tokens.
 + 
 + Returns:
 +  A `NamespaceNAme` containing all of the information about the name.
 + ++/
@safe
NamespaceName nextNamespaceName(R)(ref R lex)
{
    // Read in names until a semi-colon is hit.
    auto    info = lex.front.info;
    Token[] toks;
    while(true)
    {
        enforce(!lex.empty, new ASTException("Unexpected EoF", info));
        
        if(lex.front.type == TokenType.OP_OPERATION_END)
        {
            lex.popFront;
            break;
        }
        else
        {
            enforce(lex.front.type == TokenType.UNIQ_IDENTIFIER || lex.front.type == TokenType.OP_NAMESPACE_SEPERATOR,
                new ASTException(format("Expected an Identifier, or a '/' for a namespace, not a %s", lex.front.type), lex.front.info));
            
            toks ~= lex.front;
            lex.popFront;
        }
    }
    enforce(toks.length > 0, new ASTException("Umm... No tokens were read in for a namespace's name. Unexpected EoF?", info));

    return NamespaceName(toks);
}
///
unittest
{
    import std.exception : assertThrown;

    auto lex = Lexer(r"
        Hello/From/The/Other/Slash;
        This:Is:Invalid
    ");

    auto name = lex.nextNamespaceName;
    assert(name.segments == ["Hello", "From", "The", "Other", "Slash"]);
    assert(name.fullName == "Hello/From/The/Other/Slash");

    assertThrown!ASTException(lex.nextNamespaceName);

    lex = Lexer("Hello");
    assertThrown!ASTException(lex.nextNamespaceName);
}

/++
 + Reads in the next class.
 + 
 + Throws:
 +  `ASTException` if something is invalid.
 + 
 + Params:
 +  lex = The input range of tokens.
 + 
 + Returns:
 +  A `ClassNode` containing all of the information about the class.
 + ++/
@safe
ClassNode nextClass(R)(ref R lex)
{
    lex.front.enforceToken(TokenType.KEY_CLASS, ".class");
    lex.popFront;

    // Read in the name
    auto name = lex.front;
    lex.front.enforceToken(TokenType.UNIQ_IDENTIFIER, "an Identifier for a class' name");
    lex.popFront;

    // Then any attributes
    AttributeNode[] attribs;
    while(true)
    {
        enforce(!lex.empty, new ASTException("Unexpected EoF", name.info));

        if(lex.front.type == TokenType.OP_CURLY_LEFT)
        {
            lex.popFront;
            break;
        }

        attribs ~= lex.nextAttribute;
    }

    // Create the class, then being to read in any functions.
    auto node = new ClassNode(name, attribs);

    while(true)
    {
        enforce(!lex.empty, new ASTException("Unexpected EoF", name.info));
        
        if(lex.front.type == TokenType.OP_CURLY_RIGHT)
        {
            lex.popFront;
            break;
        }

        auto next = lex.front;
        if(next.type == TokenType.KEY_FUNCTION)
            node.registerFunction(lex.nextFunction());
    }

    return node;
}
// For ease of testing, this function is tested in nextFunction's unittest.

/++
 + Reads in the next function.
 + 
 + Throws:
 +  `ASTException` if something is invalid.
 + 
 + Params:
 +  lex = The input range of tokens.
 + 
 + Returns:
 +  A `FunctionNode` containing all of the information about the function.
 + ++/
@safe
FunctionNode nextFunction(R)(ref R lex)
{
    lex.front.enforceToken(TokenType.KEY_FUNCTION, ".function");
    lex.popFront;

    // Read the name
    auto name = lex.front;
    name.enforceToken(TokenType.UNIQ_IDENTIFIER, "an Identifier for a function's name");
    lex.popFront;

    lex.front.enforceToken(TokenType.OP_PAREN_LEFT, "(");
    lex.popFront;

    // Read in parameters
    TypeNode[] params;
    while(true)
    {
        enforce(!lex.empty, new ASTException("Unexpected EoF", name.info));

        auto next = lex.front;
        if(next.type == TokenType.OP_PAREN_RIGHT)
        {
            lex.popFront;
            break;
        }

        auto node = lex.nextValueNode;
        auto nextt = cast(TypeNode)node;
        enforce(nextt !is null, new ASTException(format("Expected a Type for a function's parameter, got %s", node.type), name.info));

        params ~= nextt;
    }

    // Read the return type
    lex.front.enforceToken(TokenType.OP_TYPE_SPECIFIER, "the function's return Type");
    auto retType = cast(TypeNode)lex.nextValueNode;

    // Read any attributes
    AttributeNode[] attributes;
    while(true)
    {
        enforce(!lex.empty, new ASTException("Unexpected EoF", name.info));

        if(lex.front.type == TokenType.OP_CURLY_LEFT)
        {
            lex.popFront;
            break;
        }

        attributes ~= lex.nextAttribute;
    }

    // Then read in the function's locals
    lex.front.enforceToken(TokenType.KEY_FUNCTION_LOCALS, ".locals at the start of a function");
    auto locals = lex.nextFuncLocals;

    // And finally, the operations.
    OpcodeNode[] codes;
    while(true)
    {
        enforce(!lex.empty, new ASTException("Unexpected EoF", name.info));

        if(lex.front.type == TokenType.OP_CURLY_RIGHT)
        {
            lex.popFront;
            break;
        }

        codes ~= lex.nextOperation;
    }

    return new FunctionNode(name, new TypeListNode(params), retType, attributes, locals, codes);
}
///
unittest
{
    auto lex = Lexer(
        r"
        .namespace Super/Test;

        .import Some/Namespace;
        .import Some/Other/Namespace;  

        .class Test [AttribThing]
        {
            .function Test(&int32 &string) &void [Static]
            {
                .locals
                {
                    &int32
                }

                push.i32 20;
            }
        }
        ");

    auto file = lex.parseCode();
    assert(file.imports[0].name.fullName == "Some/Namespace");
    assert(file.imports[1].name.segments == ["Some", "Other", "Namespace"]);

    auto space = file.namespace;
    assert(space.name.segments == ["Super", "Test"]);
    assert(space.name.fullName == "Super/Test");

    auto cls = space.classes[0];
    assert(cls.name                     == "Test");
    assert(cls.attributes[0].token.text == "AttribThing");

    auto func = cls.functions[0];

    assert(func.name                            == "Test");
    assert(func.params.types[0].token.text      == "int32");
    assert(func.params.types[1].token.text      == "string");
    assert(func.retType.token.text              == "void");
    assert(func.attributes[0].token.text        == "Static");
    assert(func.locals.types[0].token.text      == "int32");
    assert(func.ops[0].operation.text           == "push.i32");
    assert(func.ops[0].parameters[0].type       == NodeType.Number);

    // Now to test the names
    assert(func.signature == "Test&int32&string$void");
    assert(func.fullName  == "Super/Test:Test#Test&int32&string$void"); // If this passes, it generally means the Class and NamespaceNodes also would pass.
}

/++
 + Reads the next attribute. "[AttributeName]"
 + 
 + Throws:
 +  `ASTException` if something is invalid.
 + 
 + Params:
 +  lex = The input range of tokens.
 + 
 + Returns:
 +  An AttributeNode with the name of the attribute.
 + ++/
@safe
AttributeNode nextAttribute(R)(ref R lex)
{
    lex.front.enforceToken(TokenType.OP_SQUARE_LEFT, "[");
    auto info = lex.front.info;
    lex.popFront;

    auto name = lex.front;
    name.enforceToken(TokenType.UNIQ_IDENTIFIER, "an Identifier for an Attribute");
    lex.popFront;

    lex.front.enforceToken(TokenType.OP_SQUARE_RIGHT, "]");
    lex.popFront;

    return new AttributeNode(name);
}
///
unittest
{
    auto lex = Lexer("[Static]");

    assert(lex.nextAttribute.token.text == "Static");
}

/++
 + Reads in the next ".locals" blocks.
 + 
 + Throws:
 +  `ASTException` if something is invalid.
 + 
 + Params:
 +  lex = The input range of tokens.
 + 
 + Returns:
 +  A FuncLocalsNode with all of the function's local variables
 + ++/
@safe
TypeListNode nextFuncLocals(R)(ref R lex)
if(isInputRange!R && is(ElementType!R == Token))
{
    lex.front.enforceToken(TokenType.KEY_FUNCTION_LOCALS, ".locals");
    auto info = lex.front.info;
    lex.popFront;

    lex.front.enforceToken(TokenType.OP_CURLY_LEFT, "{");
    lex.popFront;

    TypeNode[] types;
    while(true)
    {
        enforce(!lex.empty, new ASTException("Unexpected EoF", info));

        auto next = lex.front;

        if(next.type == TokenType.OP_CURLY_RIGHT)
        {
            lex.popFront;
            break;
        }
        else
        {
            auto node = cast(TypeNode)lex.nextValueNode;
            enforce(node !is null, new ASTException("Expected a type for local variable definition.", next.info));

            types ~= node;
        }
    }

    return new TypeListNode(types);
}
///
unittest
{
    auto lex = Lexer(
        r"
        .locals
        {
            &string
            &int32
        }
        ");

    auto locals = lex.nextFuncLocals;
    assert(locals.types[0].token.text == "string");
    assert(locals.types[1].token.text == "int32");
}

/++
 + Creates some version of a ValueNode.
 + 
 + Throws:
 +  `ASTException` if something's incorrect.
 + 
 + Params:
 +  lex = The input range of Tokens.
 + 
 + Returns:
 +  A node representing the value found.
 + ++/
@safe
Node nextValueNode(R)(ref R lex)
if(isInputRange!R && is(ElementType!R == Token))
{
    auto next = lex.front;
    lex.popFront;

    switch(next.type) with(TokenType)
    {
        case UNIQ_STRING:
            return new StringNode(next);

        case UNIQ_NUMBER:
            return new NumberNode(next);

        case OP_TYPE_SPECIFIER:
            next = lex.front;
            lex.popFront;

            next.enforceToken(TokenType.UNIQ_IDENTIFIER, "an Indentifier");
            return new TypeNode(next);

        default:
            throw new ASTException(format("Cannot create a ValueNode from %s", next.type), next.info);
    }
}
///
unittest
{
    import std.exception : assertThrown;

    auto lex = Lexer("\"Dan is sexy\" 23 &void &23 ;");

    assert(lex.nextValueNode.type == NodeType.String);
    assert(lex.nextValueNode.type == NodeType.Number);

    auto next = cast(TypeNode)lex.nextValueNode;
    assert(next.type        == NodeType.VariableType);
    assert(next.token.text  == "void");

    assertThrown!ASTException(lex.nextValueNode);
    assertThrown!ASTException(lex.nextValueNode);
}

/++
 + Creates a new OpcodeNode.
 + 
 + Throws:
 +  `ASTException` if something's invalid.
 + 
 + Params:
 +  lex = The input range of Tokens.
 + 
 + Returns:
 +  A new OpcodeNode containing the next opcode
 + ++/
@safe
OpcodeNode nextOperation(R)(ref R lex)
if(isInputRange!R && is(ElementType!R == Token))
{
    auto op = lex.front;
    lex.popFront;

    Token[] params;
    while(true)
    {
        enforce(!lex.empty, new ASTException("Missing ';' at the end of an operation", op.info));

        auto next = lex.front;
        lex.popFront;

        if(next.type == TokenType.OP_OPERATION_END)
            break;
        else
            params ~= next;
    }

    return new OpcodeNode(op, params);
}
///
unittest
{
    import std.exception : assertThrown;

    auto lex = Lexer("push.str \"Daniel is a boob\"; debug.locals; invalidGiveMeMoobs; MissingADiva");

    void test(TokenType op, NodeType param)
    {
        auto next = lex.nextOperation;
        assert(next.operation.type == op);
        assert(next.parameters.length == 0 || next.parameters[0].type == param);
    }
    test(TokenType.CODE_PUSH_STRING,  NodeType.String);
    test(TokenType.CODE_DEBUG_LOCALS, NodeType.Opcode);

    assertThrown!ASTException(lex.nextOperation);
    assertThrown!ASTException(lex.nextOperation);
}

/++
 + Performs an enforce on a `Token`
 + 
 + Exceptions:
 +  `ASTException` if $(D t)'s type isn't the same as $(D type).
 + 
 + Params:
 +  t       = The token to peform the enforce on.
 +  type    = The type that $(D t) must be, for it to pass the enforce.
 +  wanted  = Should the enforce fail, then this message is displayed following the text "Expected ".
 +            Aka, it's just information about what the token should've been.
 + ++/
@safe
void enforceToken(Token t, TokenType type, string wanted)
{
    enforce(t.type == type,
        new ASTException(format("Expected %s [%s], got '%s' [%s]", wanted, type, t.text, t.type), t.info));
}

/++
 + Determines if the number in the node is a floating point.
 + 
 + Params:
 +  node = The number node to check.
 + 
 + Returns:
 +  `true` if the number is a floating point. `false` otherwise.
 + ++/
@safe @nogc
bool isFloatingPoint(NumberNode node) nothrow pure
{
    foreach(ch; node.token.text)
        if(ch == '.')
            return true;

    return false;
}

/// The exception that is thrown by the AST.
class ASTException : Exception
{
    public
    {
        /++
         + Creates a new ASTException.
         + 
         + Params:
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
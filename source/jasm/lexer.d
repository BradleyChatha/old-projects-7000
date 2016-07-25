/++
 + The module containing everything regarding the creation of tokens.
 + ++/
module jasm.lexer;

private
{
    import std.range, std.array, std.algorithm, std.exception;
    import std.format : format;
    import std.ascii  : isDigit, isWhite;
}

/// Contains all the different types of tokens.
enum TokenType
{
    // Keywords
    KEY_NAMESPACE,                  // .namespace
    KEY_CLASS,                      // .class
    KEY_FUNCTION,                   // .function
    KEY_FUNCTION_LOCALS,            // .locals     

    // Operators
    OP_NAMESPACE_SEPERATOR,         // name1/name2
    OP_CLASS_SELECTOR,              // namespace:class
    OP_FUNCTION_SELECTOR,           // namepsace:class#function
    OP_SQUARE_LEFT,                 // [
    OP_SQUARE_RIGHT,                // ]
    OP_CURLY_LEFT,                  // {
    OP_CURLY_RIGHT,                 // }
    OP_PAREN_LEFT,                  // (
    OP_PAREN_RIGHT,                 // )
    OP_TYPE_SPECIFIER,              // &type
    OP_OPERATION_END,               // opcode param;

    // Unique types
    UNIQ_EOF,                       // End of file
    UNIQ_STRING,                    // String
    UNIQ_NUMBER,                    // Number
    UNIQ_IDENTIFIER,                // An Identifier(Looks like a keyword, but doesn't have any meaning)
    UNIQ_UNKNOWN,                   // An unknown(therefor invalid) type.

    // Op codes, it is _very_ important that once an opcode is added, it's position in the enum must not change.
    CODE_START, // Any enum value between CODE_START and CODE_END are Opcodes

    CODE_PUSH_STRING,               // push.str STR1
                                    //  Pushes a string onto the function's stack.
                                    //      Parameter STR1 = The string to push onto the stack. Max size of 255

    CODE_PUSH_INT_32,               // push.i32 NUM1
                                    //  Pushes a 32-bit int onto the function's stack.
                                    //      Parameter NUM1 = The number to push onto the stack

    CODE_STORE_LOCAL,               // store.local NUM1
                                    //  This code takes 1 value off of the top of the stack and stores it into a local variable.
                                    //      Parmater NUM1 = The index of the local variable to store the value in.
                                    //      STACK #1      = The value to store in the local variable in the [NUM]th local

    CODE_DEBUG_LOCALS,              // debug.locals
                                    //  Prints out the value of all locals in the function to stdout.

    CODE_END, // Any enum value between CODE_START and CODE_END are Opcodes
}
private
{
    /++
     + Finds out and returns the type that $(B text) represents.
     + 
     + Example:
     + ---
     +  assert(toTokenType("Declare")    == TokenType.KEY_DECLARE);
     +  assert(toTokenType("I'm a boob") == TokenType.UNIQ_UNKNOWN);
     + ---
     + 
     + Parameters:
     +  text = The text to convert.
     + 
     + Returns:
     +  The $(B TokenType) that $(B text) represents.
     +  TokenType.UNIQ_UNKNOWN is returned if $(B text) does not represent a TokenType.
     + ++/
    TokenType toTokenType(C)(C text)
    if(is(C == string) || is(C == char))
    {
        static if(is(C == string))
        {
            switch(text) with(TokenType)
            {
                mixin(generateCases!(
                        ".namespace",           KEY_NAMESPACE,
                        ".class",               KEY_CLASS,
                        ".function",            KEY_FUNCTION,
                        ".locals",              KEY_FUNCTION_LOCALS,

                        "push.str",             CODE_PUSH_STRING,
                        "push.i32",             CODE_PUSH_INT_32,

                        "store.local",          CODE_STORE_LOCAL,

                        "debug.locals",         CODE_DEBUG_LOCALS
                        ));
                
                default:
                    return TokenType.UNIQ_UNKNOWN;
            }
        }
        else
        {
            switch(text) with(TokenType)
            {
                mixin(generateCases!(
                        '/', OP_NAMESPACE_SEPERATOR,
                        ':', OP_CLASS_SELECTOR,
                        '#', OP_FUNCTION_SELECTOR,
                        '[', OP_SQUARE_LEFT,
                        ']', OP_SQUARE_RIGHT,
                        '{', OP_CURLY_LEFT,
                        '}', OP_CURLY_RIGHT,
                        '(', OP_PAREN_LEFT,
                        ')', OP_PAREN_RIGHT,
                        '&', OP_TYPE_SPECIFIER,
                        ';', OP_OPERATION_END
                        ));
                
                default:
                    return TokenType.UNIQ_UNKNOWN;
            }
        }
    }
    unittest
    {
        assert(toTokenType(".namespace") == TokenType.KEY_NAMESPACE);
        assert(toTokenType("I'm a boob") == TokenType.UNIQ_UNKNOWN);
        assert(toTokenType('&')          == TokenType.OP_TYPE_SPECIFIER);
        assert(toTokenType('2')          == TokenType.UNIQ_UNKNOWN);
    }
}

/// Contains debug information about a token
struct TokenDebugInfo
{
    /// The file the token was made in.
    string file;

    /// The line the token was made(May be inaccurate).
    size_t line;

    /// The column the token was made on the line(May be inaccruate).
    size_t column;
}

/// Contains data about a token
struct Token
{
    /// What kind of token this is.
    TokenType       type;

    /// The text that makes up the token.
    string          text;

    /// Debug information for the token.
    TokenDebugInfo  info;
}

/// Lexes source code into Tokens.
/// Acts as an InputRange
class Lexer
{
    /// Private variables (I like to keep private functions and variables seperated, if the private functions are massive)
    private
    {
        string  _code;
        size_t  _index;

        TokenDebugInfo  _debug;
        Token           _front;

        /++
         + Private constructor, for unittests.
         + 
         + Parameters:
         +  pop = True if popFront should be called. False otherwise.
         + ++/
        @safe
        this(string code, string fileName, bool pop)
        {
            this._code  = code;
            this._index = 0;
            this._debug = TokenDebugInfo(fileName, 1, 1);

            if(pop)
            {
                this.popFront();
            }
        }
    }

    @safe
    public
    {
        /++
         + Constructs a new lexer that will lex the code given to it.
         + 
         + Parameters:
         +  code = The code to lex.
         +  fileName = Debug information. This is given to the debug data for each token this lexer creates.
         + ++/
        this(string code, string fileName = "NoFile")
        {
            this(code, fileName, true);
        }

        /++
         + Lexes the next token.
         + ++/
        void popFront()
        {
            this._front = this._nextToken();
        }

        /++
         + Returns:
         +  The last token parsed.
         + ++/
        @property
        Token front()
        {
            return this._front;
        }

        /++
         + Determines if there are no more tokens to be lexed.
         + This is done by checking if the front of the range is a TokenType.UNIQ_EOF token.
         + 
         + Returns:
         +  True if there's no tokens left to lex (determined by the EOF token). False otherwise.
         + ++/
        @property
        bool empty()
        {
            return (this.front.type == TokenType.UNIQ_EOF);
        }
    }

    /// Private functions
    @safe
    private
    {
        /++
         + Reads and returns the next character.
         + Handles updating the _debug field for debug tokens.
         + 
         + Parameters:
         +  escape = If True, handles escape characters. False otherwise.
         + 
         + Throws:
         +  $(B LexerException) if EoF was reached.
         +  $(B LexerException) if an invalid escape character was read in.
         + 
         + Returns:
         +  The next character in the code.
         + ++/
        char _nextChar(bool escape = false)
        {
            enforce(this._index < this._code.length, new LexerException("Cannot read past the end of the code.", this._debug));

            char c = this._code[this._index++];
            this._debug.column += 1;

            // Handle escape characters
            if(escape && c == '\\')
            {
                c = this._nextChar(false);

                switch(c)
                {
                    mixin(generateCases!(
                            'n', '\n',
                            't', '\t',
                            'r', '\r',
                            '\\', '\\',
                            '"', '"'
                            ));

                    default:
                        throw new LexerException("Unknown escape character: '"~c~"'", this._debug);
                }
            }

            // Update the debug info
            if(c == '\n')
            {
                this._debug.column = 1;
                this._debug.line += 1;
            }

            return c;
        }
        unittest
        {
            string code = "a b\\t\nc";
            auto lex = new Lexer(code, "NoFile", false);

            // Reading in normal characters, and advancing the column.
            assert(lex._nextChar(false) == 'a');
            assert(lex._nextChar(false) == ' ');
            assert(lex._debug.column == 3);

            // Same as above, but also has a test for an escape character.
            assert(lex._nextChar(false) == 'b');
            assert(lex._nextChar(true)  == '\t');
            assert(lex._debug.column == 6);

            // Tests to make sure it handles new lines characters.
            assert(lex._nextChar(false) == '\n');
            assert(lex._debug.column == 1 && lex._debug.line == 2);
            assert(lex._nextChar(false) == 'c');

            // Makes sure an exception is thrown on EoF.
            assertThrown!LexerException(lex._nextChar());
        }

        /++
         + Moves the _index and debug.column back by 1 value.
         + NOTE: Certain cases can cause this function to create undesired behaviour(namely, incorrect debug info).
         + ++/
        void _stepBack()
        {
            // Stop an underflow.
            if(this._index == 0)
            {
                return;
            }

            this._index         -= 1;
            this._debug.column  -= 1;
        }

        /++
         + Advances the lexer over whitespace characters.
         + ++/
        void _skipSpaces()
        {
            // First, skip white spaces
            while(true)
            {
                // Break on EoF
                if(this._index >= this._code.length)
                {
                    break;
                }

                // Break if we read in a non-whitespace character.
                // Also, set the index back by 1.
                if(!isWhite(this._nextChar(false)))
                {
                    this._stepBack();
                    break;
                }
            }

            // Then, skip comments and try to skip whitespace again.
            if(this._index <= this._code.length - 2)
            {
                if(this._nextChar(false) == '/')
                {
                    if(this._nextChar(false) == '/')
                    {
                        while(true)
                        {
                            // Break on EoF
                            if(this._index >= this._code.length || this._nextChar(false) == '\n')
                            {
                                break;
                            }
                        }

                        this._skipSpaces();
                    }
                    else
                    {
                        this._stepBack();
                        this._stepBack();
                    }
                }
                else
                {
                    this._stepBack();
                }
            }
        }
        unittest
        {
            auto lex = new Lexer("a \t\r\n// Super comments!\nb\t\t\t", "NoFile", false);

            assert(lex._nextChar() == 'a');
            lex._skipSpaces();
            assert(lex._debug.line == 3 && lex._debug.column == 1); // Make sure the debug information stays correct.
            assert(lex._nextChar() == 'b');

            // Make sure it doesn't throw an exception for EoF
            assertNotThrown!LexerException(lex._skipSpaces());
        }

        /++
         + Parses and returns a string token.
         + 
         + Throws:
         +  $(B LexerException) if the string is invalid in some way.
         + 
         + Returns:
         +  A TokenType.UNIQ_STRING token.
         + ++/
        Token _nextStringToken()
        {
            this._skipSpaces();

            // Make sure there's actually a string next.
            version(unittest)
            {
                // The unittest for this function wants to make sure this is thrown properly <3
                enforce(this._nextChar() == '"', new LexerException("This function shouldn't have been called.", this._debug));
            }
            else
            {
                assert(this._nextChar() == '"', "This function shouldn't have been called.");
            }

            // This functino needs to reset the index(and therefor the debug info) later on.
            // So keep the old values stored.
            auto oldDebug = this._debug;
            auto oldIndex = this._index;
            auto toReturn = Token(TokenType.UNIQ_STRING, "", this._debug);

            // First, find out how large the string is.
            size_t size = 0;
            while(true)
            {
                enforce(this._index < this._code.length, new LexerException("Unterminated string.", this._debug));

                auto chr = this._nextChar();

                if(chr == '"')
                {
                    break;
                }
                else if(chr == '\\')
                {
                    // For escape characters, skip over the character after the "\"
                    size += 1;
                    this._nextChar();
                }
                else
                {
                    size += 1;
                }
            }

            // Pre-allocate the array of the string(to stop a constant reallocation of the of array)
            toReturn.text.reserve(size);

            // And then go back over the string
            this._index = oldIndex;
            this._debug = oldDebug;
            for(auto i = 0; i < size; i++)
            {
                toReturn.text ~= this._nextChar(true);
            }
            enforce(this._nextChar() == '"', new LexerException("Unterminated string.", this._debug));

            return toReturn;
        }
        unittest
        {
            void tryToThrow(string code)
            {
                auto lex = new Lexer(code, "NoFile", false);
                assertThrown!LexerException(lex._nextStringToken());
            }
            tryToThrow("No Starting Speech Mark\"");
            tryToThrow("\"No Ending Speech Mark");

            auto lex = new Lexer("\"First String\" \"Second String\"");
            assert(lex.front.type == TokenType.UNIQ_STRING);
            assert(lex.front.text == "First String");
            lex.popFront();

            assert(lex.front.text == "Second String");
            lex.popFront();

            assert(lex.empty);
        }

        /++
         + Parses and returns the next number token.
         + Numbers are always assumed to be floating point.
         + 
         + Throws:
         +  $(B LexerException) if something is wrong with parsing the token.
         + 
         + Returns:
         +  A TokenType.UNIQ_NUMBER token.
         + ++/
        Token _nextNumberToken()
        {
            this._skipSpaces();

            // This should never be called unless the next character is a digit
            auto n = this._nextChar();
            version(unittest)
            {
                // The unittest for this function wants to make sure this is thrown properly <3
                enforce(isDigit(n) || n == '-', new LexerException("This function shouldn't have been called.", this._debug));
            }
            else
            {
                assert(isDigit(n) || n == '-', "This function shouldn't have been called.");
            }
            this._stepBack();

            // Do a similar thing _nextStringToken does, figure out how long the number is. And set it's text to a slice of the code.
            auto toReturn = Token(TokenType.UNIQ_NUMBER, "", this._debug);
            auto start = this._index;

            while(true)
            {
                // Numbers don't have any predefined ending, so EoF may instead end it.
                if(this._index >= this._code.length)
                {
                    break;
                }

                auto chr = this._nextChar();
                if(!isDigit(chr) && chr != '.' && chr != '-')
                {
                    this._stepBack();
                    break;
                }
            }

            // Slice the code to set it's text.
            toReturn.text = this._code[start..this._index];

            return toReturn;
        }
        unittest
        {
            auto lex = new Lexer("40 200.4964 -40", "NoFile", false);

            assert(lex._nextNumberToken.text == "40");
            assert(lex._debug.column == 3);
            assert(lex._nextNumberToken.text == "200.4964");
            assert(lex._nextNumberToken.text == "-40");

            lex.popFront();
            assert(lex.empty);

            // Make sure it throws an exception
            lex = new Lexer(".59", "NoFile", false);
            assertThrown!LexerException(lex._nextNumberToken);
        }

        /++
         + Returns the next identifier/keyword.
         + 
         + Returns:
         +  Returns either a TokenType.UNIQ_IDENTIFIER or a TokenType.KEY_*** token.
         ++/
        Token _nextIdentifierToken()
        {
            this._skipSpaces();
            string text  = "";
            auto   start = this._index;

            // Find out how large the identifier is.
            while(true)
            {
                // Break on EoF
                if(this._index >= this._code.length)
                {
                    break;
                }

                // Break if some special character or space is reached.
                auto chr = this._nextChar();
                if(isWhite(chr) || chr.toTokenType() != TokenType.UNIQ_UNKNOWN)
                {
                    this._stepBack();
                    break;
                }
            }
            assert(start != this._index); // This function shouldn't have been called at EoF

            // Then create the token
            text        = this._code[start..this._index];
            auto type   = text.toTokenType();
            type        = (type == TokenType.UNIQ_UNKNOWN) ? TokenType.UNIQ_IDENTIFIER : type;

            return Token(type, text, this._debug);
        }
        unittest
        {
            auto lex = new Lexer(".function Main()");

            assert(lex.front.type == TokenType.KEY_FUNCTION);
            lex.popFront();

            assert(lex.front.type == TokenType.UNIQ_IDENTIFIER);
            assert(lex.front.text == "Main");
            lex.popFront();

            assert(lex.front.type == TokenType.OP_PAREN_LEFT); // Tests to make sure operators aren't included into identifiers' names.
            lex.popFront();

            assert(lex.front.type == TokenType.OP_PAREN_RIGHT);
            lex.popFront();

            assert(lex.empty);
        }

        /++
         + Returns the next operator token.
         + 
         + Returns:
         +  The next operator token.
         + ++/
        Token _nextOperatorToken()
        {
            this._skipSpaces();
            auto toReturn = Token(TokenType.UNIQ_UNKNOWN, "", this._debug);

            // Get the token type of the next character.
            auto chr        = this._nextChar();
            toReturn.type   = chr.toTokenType();
            toReturn.text   ~= chr;
            assert(toReturn.type != TokenType.UNIQ_UNKNOWN, "This function shouldn't have been called.");

            return toReturn;
        }
        unittest
        {
            auto lexer = new Lexer(":# /", "NoFile", false);
            void assertNext(TokenType wanted, string text)
            {
                auto next = lexer._nextOperatorToken;
                assert(next.type == wanted);
                assert(next.text == text);
            }

            assertNext(TokenType.OP_CLASS_SELECTOR,         ":");
            assertNext(TokenType.OP_FUNCTION_SELECTOR,      "#");
            assertNext(TokenType.OP_NAMESPACE_SEPERATOR,    "/");

            lexer.popFront();
            assert(lexer.empty);
        }

        /++
         + Parses and returns the next token.
         + 
         + Returns:
         +  The next token.
         + ++/
        Token _nextToken()
        {
            this._skipSpaces();

            // Check if we're at EOF
            if(this._index >= this._code.length)
            {
                return Token(TokenType.UNIQ_EOF, "", this._debug);
            }

            // Figure out what the next token is, depending on the next character.
            auto chr = this._nextChar();

            // First, check to see if it's an operator
            auto type = chr.toTokenType();
            if(type != TokenType.UNIQ_UNKNOWN)
            {
                this._stepBack();
                return this._nextOperatorToken();
            }
            else if(chr == '"') // Check to see if it's a string
            {
                this._stepBack();
                return this._nextStringToken();
            }
            else if(isDigit(chr) || chr == '-') // Check to see if it's a number
            {
                this._stepBack();
                return this._nextNumberToken();
            }
            else // Otherwise, treat it as an identifier/keyword.
            {
                this._stepBack();
                return this._nextIdentifierToken();
            }

            assert(0);
        }
        unittest
        {
            auto lex = new Lexer("& (\n \"This is a string\" 3.1425 .function Daniel");

            // Test for operators
            assert(lex.front.type == TokenType.OP_TYPE_SPECIFIER);
            lex.popFront();

            assert(lex.front.type == TokenType.OP_PAREN_LEFT);
            lex.popFront();

            // Test for strings
            assert(lex.front.type == TokenType.UNIQ_STRING);
            assert(lex.front.text == "This is a string");
            lex.popFront();

            // Test for numbers
            assert(lex.front.type == TokenType.UNIQ_NUMBER);
            assert(lex.front.text == "3.1425");
            lex.popFront();

            // Test for identifiers/keywords
            assert(lex.front.type == TokenType.KEY_FUNCTION);
            lex.popFront();

            assert(lex.front.type == TokenType.UNIQ_IDENTIFIER);
            assert(lex.front.text == "Daniel");
            lex.popFront();

            // Test for EoF
            assert(lex.empty);
        }
    }
}

/// The exception that is thrown by the Lexer.
class LexerException : Exception
{
    public
    {
        /++
         + Creates a new LexerException.
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

private
{
    // This function exists becauase I'm *super* lazy, and 'case "whatevs": return TokenType.SASS_OVERLOAD;' is too much work to write.
    /++
     + Generates cases for a switch statement.
     + General format for the template parameters is: ("someValue", enumThing)
     + TODO: Finish this god-awful documentation.
     + ++/
    string generateCases(T...)()
    {
        static assert((T.length > 0) && (T.length % 2) == 0, "The amount of arguments given must be even.");
        string code = "";
        
        string value = "";
        foreach(i, thing; T)
        {
            if((i % 2) == 1 && (i != 0))
            {
                code ~= format("case %s: return %s;", value, thing.stringof);
                continue;
            }
            else
            {
                value = thing.stringof;
            }
        }
        
        return code;
    }
    unittest
    {
        auto test()
        {
            switch("This is just to make sure it compiles")
            {
                mixin(generateCases!(
                        "This", TokenType.UNIQ_EOF,
                        "Help Me", TokenType.UNIQ_STRING,
                        "No", TokenType.UNIQ_NUMBER
                        ));
                
                default:
                    break;
            }
            
            switch(';')
            {
                mixin(generateCases!(
                        '.', TokenType.UNIQ_IDENTIFIER,
                        '2', TokenType.UNIQ_EOF
                        ));
                
                default:
                    break;
            }
            return TokenType.UNIQ_IDENTIFIER;
        }
        test();
    }
}
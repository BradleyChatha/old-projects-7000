/++
 + Contains code for a (witty named) event dispatcher.
 + ++/
module jengine.core.post;

private
{
    import std.experimental.logger, std.experimental.allocator.mallocator, std.experimental.allocator;
    import jengine.core.engine : IInitialisable, Engine;
}

/++
 + The base class for any mail that can be posted to a `PostOffice`.
 + ++/
abstract class Mail
{
    /// The type used as the Mail's type.
    alias MailTypeT = ushort;
    private
    {
        MailTypeT _type;
    }

    public
    {
        /++
         + Base constructor for `Mail`.
         + 
         + Params:
         +  type = The type of data this mail represents.
         +         e.g. MyMailTypes.CLOSE_WINDOW
         + ++/
        @safe @nogc
        this(MailTypeT type) nothrow
        {
            this._type = type;
        }

        /++
         + Notes:
         +  The mail's type is just a number associated with it, it's generally used as a "command".
         +  For example, a mail of type "SomeEnum.DESTROY_WINDOW" would tell something to destroy it's window.
         + 
         + Returns:
         +  The type of the `Mail`.
         + ++/
        @property @safe @nogc
        MailTypeT type() nothrow pure const
        {
            return this._type;
        }
    }
}
///
unittest
{
    class C : Mail
    {
        this()
        {
            super(20);
        }
    }
    auto c = new C();
    assert(c.type == 20);
}

/++
 + The interface for any class that can subscribe for any kind of `Mail` at a `PostOffice`.
 + ++/
interface IPostBox
{
    /++
     + Called when any mail is mailed to a `PostOffice` the class is subscribed to.
     + 
     + Usage:
     +  $(P Inheriting class `PostOffice.subscribe`s to a post office.)
     +  $(P Some other part of the code posts a mail of any type.)
     +  $(P Inheriting class is given the mail, and decides whether it's worth of it's time or not.)
     + 
     + Assertions:
     +  Neither parameter can be `null`.
     + 
     + Notes:
     +  A helper mixin function `IPostBox.generateOnMail` can be used to map functions annotated with `@MailBox`
     +  automagically to a message (Praise be for D's super easy yet powerful meta-programming).
     + 
     + Params:
     +  office = The office that recieved the mail.
     +  mail   = The `Mail` that was posted.
     + ++/
    void onMail(PostOffice office, Mail mail)
    in
    {
        assert(office !is null, "The PostOffice is null.");
        assert(mail   !is null, "The mail is null. (senpai didn't love you enough)");
    }

    /++
     + Generates the `onMail` function, that will look over a type, and generate a switch-case statement that maps
     + a certain type of mail (defined using `@MailBox(SomeNumber)` on a function) to a function.
     + 
     + Notes:
     +  Any `@MailBox` function should only contain two parameters, which is a `PostOffice`, and a
     +  class that inherits from `Mail` in some way.
     + 
     +  The mail recieved will be casted to this type, and an assert is thrown if the mail recieved could not be casted to
     +  the type of the function's second parameter(which should be the class inehriting `Mail`).
     + 
     + Params:
     +  T = The class to make the `onMail` function for.
     + ++/
    public static final string generateOnMail(T : IPostBox)()
    {
        import std.meta;
        import std.traits;
        import std.format;
        import std.array     : array;
        import std.algorithm : splitter;

        string output  = "void onMail(PostOffice office, Mail mail)\n{";
               output ~= "\tswitch(mail.type)\n\t{";

        alias funcs = getSymbolsByUDA!(T, MailBox);
        static assert(allSatisfy!(isSomeFunction, funcs), "@MailBox can only be used on functions.");

        foreach(func; funcs)
        {
            enum udas = getUDAs!(func, MailBox);
            static assert(udas.length == 1, "Only 1 @MailBox may be used. Offender = " ~ func.stringof);

            enum  funcName    = fullyQualifiedName!func;
            enum  uda         = udas[0];
            alias paramTypes  = Parameters!func;
            static assert(paramTypes.length == 2,           "An @MailBox function should only have 2 parameters.");
            static assert(is(paramTypes[0]  == PostOffice), "The first parameter to an @MailBox function should be a PostOffice.");
            static assert(is(paramTypes[1]   : Mail),       "The second parameter to an @MailBox function should be a class that inherits from Mail.");

            output ~= format("\t\tcase %s:\n",                                                                    uda.type);
            output ~= format("\t\t\tauto casted = cast(%s)mail;\n",                                               paramTypes[1].stringof);
            output ~= format("\t\t\tassert(casted !is null, \"For mailbox %s, unable to cast mail to %s.\");\n",  funcName, paramTypes[1].stringof);
            output ~= format("\t\t\t%s(office, casted);\n",                                                       funcName.splitter(".").array[$-1]);
            output ~= format("\t\t\tbreak;\n");
        }

        output ~= "\t\tdefault: break;\n";
        output ~= "\n\t}\n}";
        return output;
    }
    ///
    unittest
    {
        static class C : IPostBox
        {
            mixin(IPostBox.generateOnMail!C);

            bool eventCalled = false;

            @MailBox(1)
            void onSomeEvent(PostOffice office, ValueMail!bool mail)
            {
                assert(mail.type == 1);
                assert(mail.value);

                eventCalled = true;
            }

            @MailBox(400)
            void onOtherEvent(PostOffice office, CommandMail mail)
            {
                assert(mail.type == 400);
            }
        }

        auto office = new PostOffice(); // This isn't used in the example, but "onMail" requires it to have a non-null office.
        auto myC    = new C();
        assert(!myC.eventCalled);
        myC.onMail(office, new ValueMail!bool(1, true));
        myC.onMail(office, new CommandMail(400));
        assert(myC.eventCalled);
    }
}

/++
 + A UDA to be attached to a function.
 + 
 + Please see `IPostBox.generateOnMail` for a proper description on how to use this UDA.
 + ++/
struct MailBox
{
    /// The type of `Mail` this function should map to.
    Mail.MailTypeT type;
}

/++
 + The post office is where classes may subscribe (and unsubscribe) to certain types of messages, as well as post
 + mail to the office, alerting any subscribers of the mail.
 + 
 + It is essentially an event dispatcher, just with a fancy (stupid) name.
 + ++/
final class PostOffice : IInitialisable!Engine
{
    import jaster.containers;

    /++
     + The function type given when subscribing to a specific mail type.
     + 
     + Params:
     +  office = The `PostOffice` that is delivering the mail.
     +  mail   = The `Mail` that's been delievered.
     + ++/
    alias OnMailFunc = void delegate(PostOffice office, Mail mail);

    private
    {
        struct Subscriber
        {
            OnMailFunc      func;
            Mail.MailTypeT  type;
        }

        struct EnumRange
        {
            Mail.MailTypeT min;
            Mail.MailTypeT max;
        }

        DynamicArray!Subscriber _subscribers;
        DynamicArray!IPostBox   _postboxes;
        DynamicArray!EnumRange  _reserved;
        Engine                  _engine;
    }

    public
    {
        /++
         + Initialises the PostOffice.
         + 
         + Params:
         +  engine = The `Engine` being used.
         + ++/
        void onInit(Engine engine)
        {
            trace("[Initialising a PostOffice]");
            assert(engine !is null, "Attempted to initialise the PostOffice with a null Engine.");
            this._engine = engine;
        }

        /++
         + Uninitialises the PostOffice.
         + ++/
        void onUninit()
        {
            trace("[Uninitialising a PostOffice]");
            this._engine             = null;
            this._subscribers.length = 0;
            this._postboxes.length   = 0;
            this._reserved.length    = 0;
            this._subscribers.shrink();
            this._postboxes.shrink();
            this._reserved.shrink();
        }

        /++
         + Mails a message to any subscriber of the mail's `Mail.type`
         + 
         + Assertions:
         +  `mail` must not be `null`.
         + 
         + Params:
         +  mail = The mail to send.
         + ++/
        void mail(M : Mail)(M mail)
        {
            import std.algorithm : filter, each;
            assert(mail !is null, "The mail to send is null.");

            this._subscribers.range.filter!(s => s.type == mail.type)
                                   .each  !(s => s.func(this, mail));

            this._postboxes.range.each!(p => p.onMail(this, mail));
        }

        /++
         + Subscribes a delegate to a certain type of `Mail`.
         + 
         + Description:
         +  When a message that has the same `Mail.type` as `type` is mailed, then `onDeliver` is called.
         + 
         + Notes:
         +  $(P `onDeliver` $(B must) be used in `unsubscribe` before the host object is destroyed, otherwise it's very likely
         +      for a crash to occur.)
         +  $(P This function will return `onDeliver`, this is because if code such as `office.subscribe(0, (PostOffice p, Mail m) {})`
         +      is used, then there's no way to actually unsubscribe the lambda, since the calling code won't have any reference
         +      to it. Therefor `onDeliver` is returned so the calling code can store it for unsubscribing.)
         +  $(P For example - `auto lambda = office.subscribe(0, (PostOffice p, Mail m){}); /* Later on */ office.unsubscribe(lambda);`)
         + 
         + Assertions:
         +  `onDeliver` must not be `null`.
         + 
         + Params:
         +  type        = The type of mail to subscribe to.
         +  onDeliver   = The delegate to deliver any `Mail` of type `type` to.
         + 
         + Returns:
         +  `onDeliver`, see the Notes section as to why.
         + ++/
        @trusted
        OnMailFunc subscribe(Mail.MailTypeT type, OnMailFunc onDeliver)
        {
            assert(onDeliver !is null, "The delegate to subscribe to is null.");
            tracef("[Subscribing delegate %s for type %s, for post office %s.]", onDeliver, type, this);
            this._subscribers ~= Subscriber(onDeliver, type);

            return onDeliver;
        }

        /++
         + Unsubscribes a delegate from all of the mail types it's subscribed to.
         + 
         + Assertions;
         +  $(P `onDeliver` must not be null.)
         +  $(P `onDeliver` must have been previously subscribed. It's technically harmless for it not to have been, but
         +      it's probably the sign of a bug in the caller's code.)
         + 
         + Params:
         +  onDeliver = The delegate to try to find and unsubscribe.
         + ++/
        @trusted
        void unsubscribe(OnMailFunc onDeliver)
        {
            import std.algorithm : countUntil;
            assert(onDeliver !is null, "The delegate to unsubscribe to is null.");

            tracef("[Unsubscribing delegate %s from post office %s.]", onDeliver, this);
            auto result = this._subscribers.range.countUntil!"a.func == b"(onDeliver);
            assert(result != -1, "Attempted to unsubscribe a delegate that hasn't been subscribed yet.");

            this._subscribers.removeAt(result);
        }

        /++
         + Subscribes a postbox to listen to any `Mail` that is posted to the `PostOffice`.
         + 
         + Description:
         +  Anytime a `Mail` is mailed to a `PostOffice`, the mail is first sent to any specific subscribers of the function,
         +  (see the overload that takes an `OnMailFunc`) and is then sent to every `IPostBox` that is subscribed.
         + 
         + Assertions:
         +  `postBox` must not be `null`.
         + 
         + Params:
         +  postBox = The `IPostBox` to subscribe.
         + 
         + See_Also:
         +  `IPostBox.generateOnMail`
         + ++/
        @trusted
        void subscribe(IPostBox postBox)
        {
            assert(postBox !is null, "The postbox to subscribe is null.");
            tracef("[Subscribing postbox %s for post office %s.]", postBox, this);
            this._postboxes ~= postBox;
        }

        /++
         + Unsubscribes a postbox from listening to any `Mail`.
         + 
         + Assertions:
         +  $(P `postBox` must not be null.)
         +  $(P `postBox` must have been previously subscribed. It is deemed a bug in the caller's code if this function
         +      is called on an non-subscribed `IPostBox`.)
         + 
         + Params:
         +  postBox = The `IPostBox` to unsubscribe.
         + ++/
        @trusted
        void unsubscribe(IPostBox postBox)
        {
            import std.algorithm : countUntil;
            assert(postBox !is null, "The postbox to unsubscribe is null.");

            tracef("[Unsubscribing postbox %s from post office %s.]", postBox, this);
            auto result = this._postboxes.range.countUntil(postBox);
            assert(result != -1, "Attempted to unsubscribe a postbox that hasn't been subscribed yet.");
            
            this._postboxes.removeAt(result);
        }

        /++
         + Determines if a certain `OnMailFunc`/`IPostBox` is subscribed.
         + 
         + Params:
         +  subscriber = The `OnMailFunc`/`IPostBox` to look for.
         + 
         + Returns:
         +  `true` if `subscriber` has been subscribed.
         +  `false` if `subscriber` has not been subscribed.
         + ++/
        @safe @nogc
        bool isSubscribed(OnMailFunc subscriber) nothrow // JLib Issue #18 needs to be completed for this to be marked const.
        {
            import std.algorithm : canFind;
            return this._subscribers.range.canFind!(s => s.func == subscriber);
        }

        /// Ditto
        @trusted
        bool isSubscribed(IPostBox subscriber) // And for some reason, canFind isn't nothrow e_e in this case
        {
            import std.algorithm : canFind;
            return this._postboxes.range.canFind!(po => po == subscriber);
        }

        /++
         + Given an enum, a check is made to make sure every value in the enum hasn't be reserved yet.
         + 
         + Assertions:
         +  $(P Every value in `E` must have not been included in any previous enum passed to this function.)
         +  $(P `E` must follow a standard pattern of `enum E {A = 1, B = 2, C = 3, etc...}` where the next enum value
         +      is, `next = previous + 1`)
         + 
         + Description:
         +  Because the type of a `Mail` can be designed so there are multiple enums (e.g `enum WindowMailTypes`,
         +  `enum SceneMailTypes` etc.) this function can be used to make sure there are no conflics between any
         +  other `enum`s that are planned to be used with this office.
         + 
         +  It is basically a way to enforce no conflicts between different enums of `Mail` types.
         + ++/
        @trusted
        void reserveTypes(E)()
        if(is(E == enum))
        {
            import std.traits : EnumMembers;
            enum members = EnumMembers!E;
            static assert(is(typeof(members[0]) : Mail.MailTypeT), "The members of "~E.stringof~" are not implicitly convertable to "~Mail.MailTypeT.stringof);

            foreach(i, member; members)
            {
                static if(i == 0)
                    continue;
                else
                    static assert(cast(Mail.MailTypeT)member == cast(Mail.MailTypeT)(members[i - 1] + 1),
                                  "The members of " ~ E.stringof ~ " are not formatted correctly. Offender = " ~ member.stringof);
            }

            auto range = EnumRange(E.min, E.max);
            foreach(reserved; this._reserved)
            {
                bool fail = false;
                if(range.min    >= reserved.min && range.min    <= reserved.max) fail = true;
                if(range.max    >= reserved.min && range.max    <= reserved.max) fail = true;
                if(reserved.max >= range.min    && reserved.max <= range.max)    fail = true;
                if(reserved.min >= range.min    && reserved.min <= range.max)    fail = true;

                assert(!fail, "The enum " ~ E.stringof ~ " is causing a conflict.");
            }

            this._reserved ~= range;
        }
        ///
        unittest
        {
            enum A : Mail.MailTypeT
            {
                A = 0,
                B = 1,
                C = 2
            }

            enum B : Mail.MailTypeT
            {
                A = 4,
                B = 5,
                C = 6
            }

            enum C : Mail.MailTypeT
            {
                A = 3,
                B = 4
            }

            auto office = new PostOffice();
            office.reserveTypes!A; // Fine, no conflicts
            office.reserveTypes!B; // Fine, no conflicts
            //office.reserveTypes!C; // Not fine, conflicts with B
        }

        /++
         + Returns:
         +  `true` if the office has been initialised.
         +  `false` otherwise.
         + ++/
        @property @safe @nogc
        bool hasInit() nothrow pure const
        {
            return (this._engine !is null);
        }

        /++
         + Returns:
         +  The `Engine` that is being used by this office.
         + ++/
        @property @safe @nogc
        Engine engine() nothrow pure
        {
            assert(this.hasInit, "The PostOffice isn't initialised.");
            return this._engine;
        }
    }
}
///
unittest
{
    enum Command : Mail.MailTypeT
    {
        CheckIfTrue = 1,
        SetFlag     = 2
    }

    static class C : IPostBox
    {
        mixin(IPostBox.generateOnMail!C);

        @MailBox(Command.CheckIfTrue)
        void checkTrue(PostOffice, ValueMail!bool mail)
        {
            assert(mail.value);
        }
    }

    bool flag = false;
    void setFlag(PostOffice, Mail)
    {
        flag = true;
    }

    // Normally you'd want to also do "office.onInit" and "office.onUninit"
    // However, the post office doesn't actually require an instance of `Engine` to run... yet >:D
    auto office = new PostOffice();
    auto myC    = new C();
    office.reserveTypes!Command;
    office.subscribe(myC);
    office.subscribe(Command.SetFlag, &setFlag);

    assert(!flag);
    office.mailCommand(Command.SetFlag);
    assert(flag);

    office.mailValue!bool(Command.CheckIfTrue, true);

    assert(office.isSubscribed(&setFlag));
    office.unsubscribe(&setFlag);
    assert(!office.isSubscribed(&setFlag));

    assert(office.isSubscribed(myC));
    office.unsubscribe(myC);
    assert(!office.isSubscribed(myC));

    office.onUninit();
    assert(!office.hasInit);
}

/++
 + The most basic mail, all it does is simply hold a `Mail.MailTypeT`.
 + 
 + This is useful for simply mailing a command to anything that is subscribed.
 + ++/
class CommandMail : Mail
{
    public
    {
        /++
         + Creates a new CommandMail.
         + 
         + Params:
         +  command = The command to attach to the mail.
         + ++/
        @safe @nogc
        this(Mail.MailTypeT command) nothrow
        {
            super(command);
        }
    }
}

/++
 + Convinience function to mail a `CommandMail`.
 + 
 + Allocation:
 +  This function uses `Mallocator` to allocate it's message, and the message is disposed of as soon as
 +  the function exits.
 + 
 + Params:
 +  office  = The `PostOffice` to mail to.
 +  command = The command to mail.
 + ++/
void mailCommand(PostOffice office, Mail.MailTypeT command)
{
    auto mail = Mallocator.instance.make!CommandMail(command);
    scope(exit) Mallocator.instance.dispose(mail);

    office.mail(mail);
}

/++
 + A step up from `CommandMail`. A value mail is used to mail both a command, as well as a value.
 + 
 + For example, `office.mail(new ValueMail(Commands.Set_Window_Size, Vector2f(200, 400)))`
 + 
 + Params:
 +  T = The type used as the mail's value.
 + ++/
class ValueMail(T) : Mail
{
    public
    {
        /// The value of the mail.
        T value;

        /++
         + Creates a new ValueMail.
         + 
         + Params:
         +  command = The command of the mail.
         +  value   = The value of the mail.
         + ++/
        this(Mail.MailTypeT command, T value)
        {
            super(command);
            this.value = value;
        }
    }
}

/++
 + Convinience function to mail a `ValueMail`.
 + 
 + Allocation:
 +  This function uses `Mallocator` to allocate the message, which is then disposed of when the function exits.
 + 
 + Params:
 +  office  = The office to mail to.
 +  command = The command to mail.
 +  value   = The value to mail.
 + ++/
void mailValue(T)(PostOffice office, Mail.MailTypeT command, T value)
{
    alias Mail = ValueMail!T;
    auto  mail = Mallocator.instance.make!Mail(command, value);
    scope(exit)  Mallocator.instance.dispose(mail);

    office.mail(mail);
}
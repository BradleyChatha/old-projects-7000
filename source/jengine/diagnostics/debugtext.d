/// This module contains classes that will display debug text to the screen.
module jengine.diagnostics.debugtext;

private
{
    import std.experimental.logger;
    import jaster.containers;
    import jengine.core, jengine.graphics;
}

/++
 + Used to display a box with debug text on the screen.
 + 
 + Usage:
 +  The `DebugBox` will subscribe itself to a given `PostOffice`(which will generally be `Engine.events`), and will then
 +  watch out for any `DebugBox.Events` to be mailed to it. Please see the documentation for `DebugBox.Events` to see how
 +  to interact with this class.
 + 
 +  `DebugBox.onUpdate` should be called to render the box.
 + ++/
version(none)
final class DebugBox : IPostBox, IInitialisable!(Window, PostOffice)
{
    mixin(IPostBox.generateOnMail!DebugBox);

    /++
     + The events used to communicate with the DebugBox.
     + ++/
    enum Events : Mail.MailTypeT
    {
        /++
         + Adds a line of text to be drawn.
         + 
         + Each line of text added is displayed one after the other, on their own lines, in the order they were added.
         + 
         + Once the text is rendered, it'll have to be mailed again to be displayed.
         + 
         + Mail_Type:
         +  `ValueMail!string`
         + 
         + Params:
         +  value = The line of text to add.
         + 
         + Effects:
         +  The mail's value is added as a line of text to be drawn.
         + ++/
        AddText = 20,

        /++
         + Sets the position of where the debug box is drawn.
         + 
         + Mail_Type:
         +  `ValueMail!Vector2f`
         + 
         + Params:
         +  value = The top-left position of where the debug box should be drawn.
         + 
         + Effects:
         +  Sets where the box is drawn.
         + ++/
        SetPosition = 21
    }

    private
    {
        RectangleShape      _box;
        Text                _text;
        PostOffice          _office;
        Window              _window;
        DynamicArray!dchar  _buffer;

        @MailBox(Events.SetPosition)
        void onSetPos(PostOffice, ValueMail!Vector2f mail)
        {
            assert(this.hasInit, "Attempted to use an uninitialised DebugBox");
            this._box.position  = mail.value;
            this._text.position = mail.value;
        }

        @MailBox(Events.AddText)
        void onAddText(PostOffice, ValueMail!string mail)
        {
            import std.utf : byDchar;
            assert(this.hasInit, "Attempted to use an uninitialised DebugBox");

            if(this._buffer.length > 0)
                this._buffer ~= '\n';
            this._buffer ~= mail.value.byDchar;
        }
    }

    public
    {
        /++
        + Called when the class should initialise everything.
        + 
        + Params:
        +   window = The `Window` to render to.
        +   office = The `PostOffice` that this `DebugBox` will subscribe to.
        + ++/
        @trusted
        void onInit(Window window, PostOffice office)
        {
            tracef("[Initialising DebugBox that will render to Window with handle %s]", window.handle);
            this._box    = RectangleShape.create(IntRect(0, 0, 0, 0), Colour(0x30, 0x3E, 0xA8, 0xFF),
                                                 2,                   Colour(0x14, 0x1D, 0x60, 0xFF));
            this._text   = Text.create(Font.debugFont, "", Vector2f(0), 12, Colour(0xFF, 0xFF, 0xFF, 0xFF));
            this._office = office;
            this._window = window;

            office.reserveTypes!Events;
            office.subscribe(this);
        }

        /++
         + Updates and draws the debug box.
         + ++/
        @trusted
        void onUpdate()
        {
            this._text.text = this._buffer.range;
            auto renderer   = this._window.renderer;
            this._box.size  = this._text.size;
            renderer.render(this._box);
            renderer.render(this._text);

            this._text.text!char = "";
            this._buffer.length = 0;
        }
        
        /++
        + Called when the class should uninitialise everything.
        + ++/
        @trusted
        void onUninit()
        {
            RectangleShape.dispose(this._box);
            Text.dispose(this._text);
            this._office.unsubscribe(this);
            this._office = null;
            this._window = null;
        }
        
        /++
        + Returns:
        +  Whether the class has initialised or not.
        + ++/
        @property @safe @nogc
        bool hasInit() nothrow const
        {
            return (this._office !is null);
        }
    }
}
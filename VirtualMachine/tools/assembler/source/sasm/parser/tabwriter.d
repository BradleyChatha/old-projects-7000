module sasm.parser.tabwriter;

///
class TabWriter
{
    import std.array : Appender, appender;

    private
    {
        Appender!(char[]) _text;
        size_t            _tabs;
        char              _tab = '\t';
    }

    public
    {
        ///
        @safe
        void write(string text)
        {
            import std.range : repeat, take;
            this._text ~= this._tab.repeat.take(this._tabs);
            this._text ~= text;
            this._text ~= '\n';
        }

        ///
        @safe @nogc
        void entab() nothrow
        {
            if(this._tabs == size_t.max)
                return;

            this._tabs += 1;
        }

        ///
        @safe @nogc
        void detab() nothrow
        {
            if(this._tabs == 0)
                return;

            this._tabs -= 1;
        }

        ///
        @property @safe
        string text()
        {
            return this._text.data.idup;
        }
    }
}
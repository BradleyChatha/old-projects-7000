module bot.core.autodeleter;

private
{
    import vibe.d;
    import dscord.core;
    import std.algorithm : splitter, filter;
}

public
{
    import std.datetime;
}

/++
 + A class where messages can be registered to, and will be automatically removed.
 + ++/
class AutoMessageDeleter
{
    private
    {
        struct Info
        {
            Message  msg;
            SysTime  startTime; // Time it was registered at
            Duration lifeTime;  // Amount of time it's supposed to be allowed to live for.
            bool     alive;
        }

        Info[] _messages;
        Timer  _cleaner;

        void doDelete()
        {
            // First, go over every alive message and see if they need to be deleted.
            auto current = Clock.currTime;
            foreach(ref info; this._messages.filter!(i => i.alive))
            {
                auto elapsed = (current - info.startTime);
                if(elapsed >= info.lifeTime)
                {
                    info.alive = false;
                    info.msg.del();
                }
            }
        }

        void doClean()
        {
            // Then, remove all dead messages from the array
            bool decrement = false;
            for(size_t i = 0; i < this._messages.length; i++)
            {
                if(decrement)
                {
                    i -= 1;
                    decrement = false;
                }
                
                if(!this._messages[i].alive)
                {
                    if(i != this._messages.length - 1)
                        this._messages[i..$ - 1] = this._messages[i + 1..$];
                    
                    this._messages.length -= 1;
                    decrement              = true;
                }
            }
        }
    }

    public
    {
        /++
         + Queues up a message to be deleted once it's `life` time is up.
         + 
         + Params:
         +  msg             = The `Message` to delete.
         +  life            = How long the message will stay alive for before being deleted.
         +                    This time is relevent to when it was queued up, not when it was originally sent.
         +  enforceDelete   = If `true`, then `msg` must be deleteable.
         +  editWithLife    = If `true` then the lifetime of the message will be edited into it.
         + ++/
        void queue(Message msg, Duration life, bool enforceDelete = false, bool editWithLife = true)
        {
            return;
        version(none)
            {
            import std.exception : enforce;
            enforce(msg !is null,  "Attempted to queue up a null message for removal.");

            // Throw or return if we can't delete the message
            if(!msg.canDelete)
            {
                if(enforceDelete)
                    throw new Exception("Attempted to queue an undeletable message for removal.");
                else
                    return;
            }

            // Edit the message to let the user know when the message will be deleted.
            if(msg.canEdit && editWithLife)
                msg.edit(msg.content ~ format("\n<Message will be deleted in %s>", life));

            // This could possibly be improved.
            this._messages ~= Info(msg, Clock.currTime, life, true);
            setTimer(life, &doDelete);

            if(this._cleaner == Timer.init)
                this._cleaner = setTimer(5.seconds, &doClean, true);
            }
        }
    }
}
module bot.core.bot;

import vibe.d;
import dscord.core;

class SealBot : Bot
{
    import bot.core.autodeleter;
    static immutable string _configFile = "config/bot.json";
    
    private
    {
        Storage             _config;
        AutoMessageDeleter  _deleter;
    }
    
    public
    {
        this()
        {
            import std.file : exists, mkdir;
            if(!exists("config"))
                mkdir("config");
            if(!exists("storage"))
                mkdir("storage");
            
            // Setup the config stuff
            this.config.load;
            if(!this.config.has("bot_token"))      this.config.set("bot_token", VibeJSON("Bot_Token_Here"));
            if(!this.config.has("command_prefix")) this.config.set("command_prefix", VibeJSON("!"));
            
            this.config.save;
            
            // Then setup the bot
            BotConfig bconfig;
            bconfig.token             = this.config.get!string("bot_token");
            bconfig.cmdPrefix         = this.config.get!string("command_prefix");
            bconfig.cmdRequireMention = false;
            super(bconfig);
            
            this._deleter = new AutoMessageDeleter();
        }

        /++
         + Unloads the bot and it's plugins
         + ++/
        void unload()
        {
            foreach(k, v; super.plugins)
                v.unload(this);
        }
        
        /++
         + Returns:
         +  SealBot's config.
         + ++/
        @property
        Storage config()
        {
            if(this._config is null)
                this._config = new Storage(SealBot._configFile);
            
            return this._config;
        }
        
        /// Base implementation for getting a level from a user. Override this.
        override int getLevel(User user) 
        {
            return 0;
        }
        
        /// Base implementation for getting a level from a role. Override this.
        override int getLevel(Role role) 
        {
            return 0;
        }
        
        /++
         + Returns:
         +  An `AutoMessageDeleter` which can be used to queue up messages to be deleted after a certain
         +  amount of time.
         + ++/
        @property @safe @nogc
        inout(AutoMessageDeleter) deleter() nothrow inout
        {
            return this._deleter;
        }
    }
}

class HelpPlugin : Plugin
{
    public
    {
        static string[Plugin] helpInfo;

        this()
        {
            super();
        }

        @Command("help")
        void onHelp(CommandEvent e)
        {
            int count = 0;
            super.sealBot.deleter.queue(e.msg, 1.seconds, false, false);
            foreach(plugin, info; this.helpInfo)
            {
                count += 1;
                auto msg  = format("**Commands for plugin %s**\n%s", plugin.name, info);
                auto sent = e.msg.reply(msg);

                if(count == this.helpInfo.length)
                    super.sealBot.deleter.queue(sent, 2.minutes);
            }
        }
    }
}

/++
 + Converts a plugin's bot into a `SealBot`.
 + 
 + Params:
 +  plug = The `Plugin` to use.
 + 
 + Returns:
 +  The `Plugin`'s bot as a `SealBot`.
 + ++/
SealBot sealBot(Plugin plug)
{
    return cast(SealBot)plug.bot;
}
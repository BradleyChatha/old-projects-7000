module bot.plugins.fun;

private
{
    import bot.core.autodeleter, bot.core.bot;
    import dscord.core;
    import vibe.d;
}

/++
 + Allows the users to make custom memes.
 + ++/
class MemePlugin : Plugin
{
    public
    {
        string help;

        this()
        {
            auto options = new PluginOptions();
            options.useStorage = true;

            auto table = new MessageTable();
            table.setHeader (["Command",                "Description",          "Example"]);
            table.add       (["meme <name>",            "Displays a meme.",     "!meme jack"]);
            table.add       (["meme add <name> <meme>", "Adds a new meme.",     "!meme add jack I am the Rainbow Overlord!"]);
            table.add       (["meme list",              "Displays every meme.", "!meme list"]);
            table.add       (["meme remove <name>",     "Removes a meme. D:",   "!meme remove brads_social_life"]);

            // Save the storage every hour
            setTimer(1.hours, (){super.storage.save();}, true);

            this.help = table.toSendableString;
            super(options);

            HelpPlugin.helpInfo[this] = this.help;
        }

        @Command("meme")
        void onMeme(CommandEvent evt)
        {
            import std.uni       : toLower;
            import std.algorithm : splitter;
            import std.array     : array, join;

            auto seal = super.sealBot;
            void showHelp()
            {
                auto msg = evt.msg.reply(this.help);
                seal.deleter.queue(msg, 30.seconds);
            }

            seal.deleter.queue(evt.msg, 30.seconds, false, false);

            auto command = (evt.args.length > 0) ? evt.args[0] : "@@DEFAULT@@";
            switch(command)
            {
                // !meme add <name> <meme>
                case "add":
                    if(evt.args.length < 3)
                    {
                        showHelp();
                        return;
                    }

                    auto name = evt.args[1].toLower!string;
                    auto meme = evt.args[2..$].join(" ");

                    if(super.storage.has(name))
                        evt.msg.replyf("A meme called '%s' already exists!", name);

                    super.storage.set(name, VibeJSON(meme));
                    evt.msg.replyf("The great memer <@%s> has bestowed upon us the holy meme named '%s'.",
                                   evt.msg.author.id, name);
                    break;

                // !meme list
                case "list":
                    auto memes  = super.storage.obj.get!(VibeJSON[string]);
                    auto buffer = new MessageTable();
                    buffer.setHeader(["Name", "Value"]);

                    foreach(k, v; memes)
                        buffer.add([k, v.get!string]);

                    seal.deleter.queue(evt.msg.reply(buffer.toSendableString),
                                       1.minutes);
                    break;

                // !meme remove <name>
                case "remove":
                    if(evt.args.length < 2)
                    {
                        showHelp();
                        return;
                    }

                    auto name = evt.args[1];

                    // Anti-Jack code, kuku
                    if(name == "seiyuu" && evt.msg.author.id != 208582321425612801)
                    {
                        seal.deleter.queue(evt.msg.reply("Nice try, but only <@208582321425612801> can delete 'seiyuu'"),
                                           15.seconds);
                        return;
                    }

                    // See if it actually exists first.
                    if(super.storage.has(name))
                    {
                        super.storage.obj.remove(name);
                        seal.deleter.queue(evt.msg.replyf("By the power of ~~Gumi~~ <@%s>, the holy meme called '%s' has been destroyed.",
                                                          evt.msg.author.id, name),
                                           15.seconds);
                    }
                    else
                    {
                        seal.deleter.queue(evt.msg.replyf("There is no meme known as '%s'. (filthy cisgender scum)",
                                                          name),
                                           15.seconds);
                    }
                    break;

                // !meme <name> as well as just !meme <no args>
                default:
                    if(evt.args.length == 0)
                    {
                        showHelp();
                        return;
                    }

                    auto name = evt.args[0].toLower!string;
                    if(super.storage.has(name))
                        evt.msg.reply(super.storage.get!string(name));
                    else
                    {
                        seal.deleter.queue(evt.msg.replyf("404 Meme not found: %s", name), 
                                           15.seconds);
                    }
                    break;
            }
        }

        override string name()
        {
            return "CustomMemes";
        }
    }
}

/++
 + This plugin uses some random but fun APIs.
 + ++/
class FunAPIPlugin : Plugin
{
    static immutable string CAT_API_KEY     = "CAT_API_KEY";
    static immutable string GIPHY_API_KEY   = "GIPHY_API_KEY";

    public
    {
        string help;

        this()
        {
            // Setup plugin
            auto options      = new PluginOptions();
            options.useConfig = true;

            auto table = new MessageTable();
            table.setHeader (["Command",            "Description",                          "Example"]);
            table.add       (["cat [gif]",          "Get a random cat image/gif.",          "!cat, or !cat gif"]);
            table.add       (["numfact [number]",   "Get a random fact about a number.",    "!numfact 69, or !numfact"]);
            table.add       (["gif <thing>",        "Get a gif of a thing.",                "!gif penile break"]);

            this.help = table.toSendableString;
            super(options);

            HelpPlugin.helpInfo[this] = this.help;
        }

        @Command("cat")
        void onCat(CommandEvent e)
        {
            super.sealBot.deleter.queue(e.msg, 15.seconds, false, false);

            auto   type = "png"; // png, jpg, or gif
            string key  = null;

            // See if the user wants a gif
            if(e.args.length > 0 && e.args[0] == "gif")
                type = "gif";

            // See if the user has supplied a key.
            if(super.config.has(CAT_API_KEY))
            {
                try key = super.config.get!string(CAT_API_KEY);
                catch(Exception ex){}
            }
            else
                super.config.ensureObject(CAT_API_KEY);

            // Format the API call
            auto reqURL = "http://thecatapi.com/api/images/get?format=xml&results_per_page=1&type=%s%s";
            reqURL      = format(reqURL, type, (key is null) ? "" : "&api_key=" ~ key);
            
            // Then get a response!
            requestHTTP(reqURL,
                (scope HTTPClientRequest req)
                {
                    req.method = HTTPMethod.GET;
                },
                (scope HTTPClientResponse res)
                {
                    import std.regex;

                    auto contents = res.bodyReader.readAllUTF8();
                    auto reg      = ctRegex!r"<url>(.*)<\/url>";
                    auto url      = matchFirst(contents, reg)[1];

                    e.msg.reply(url);
                });
        }

        @Command("numfact")
        void onNumFact(CommandEvent e)
        {
            super.sealBot.deleter.queue(e.msg, 15.seconds, false, false);

            auto reqURL  = "http://numbersapi.com/";
                 reqURL ~= (e.args.length == 0) ? "random" : e.args[0];

            requestHTTP(reqURL,
                (scope HTTPClientRequest req)
                {
                    req.method = HTTPMethod.GET;
                },
                (scope HTTPClientResponse res)
                {                    
                    auto contents = res.bodyReader.readAllUTF8();                    
                    e.msg.reply(contents);
                });
        }

        @Command("gif")
        void onGif(CommandEvent e)
        {
            import std.string : join;
            super.sealBot.deleter.queue(e.msg, 10.seconds, false, false);

            string key = "dc6zaTOxFJmzC";
            if(super.config.has(GIPHY_API_KEY))
            {
                try key = super.config.get!string(GIPHY_API_KEY);
                catch(Exception ex){}
            }
            else
                super.config.set(GIPHY_API_KEY, Json("dc6zaTOxFJmzC"));

            auto tag    = e.args.join("+");
            auto reqURL = "http://api.giphy.com/v1/gifs/random?api_key=%s&tag=%s";
                 reqURL = format(reqURL, key, tag);

            requestHTTP(reqURL,
                (scope HTTPClientRequest req)
                {
                    req.method = HTTPMethod.GET;
                },
                (scope HTTPClientResponse res)
                {                    
                    auto contents = res.bodyReader.readAllUTF8();
                    auto json     = contents.parseJson();
                    auto url      = json["data"]["url"].get!string;

                    e.msg.replyf("Powered by Giphy\nQuery: %s\nBy: <@%s>\n%s", 
                                 tag, e.msg.author.id, url);
                });
        }

        @Command("chuck")
        void onChuckNorris(CommandEvent e)
        {
            auto url = "https://api.chucknorris.io/jokes/random";
            requestHTTP(url,
                (scope HTTPClientRequest req)
                {
                    req.method = HTTPMethod.GET;
                },
                (scope HTTPClientResponse res)
                {                    
                    auto contents = res.bodyReader.readAllUTF8();
                    auto json     = contents.parseJson();
                    auto fact     = json["value"].get!string;

                    e.msg.reply(fact);
                });
        }

        override string name()
        {
            return "FunAPIs";
        }
    }
}

class CountPlugin : Plugin
{
    public
    {
        string help;

        this()
        {
            auto options        = new PluginOptions();
            options.useStorage  = true;

            auto table = new MessageTable();
            table.setHeader (["Command",                    "Description",                          "Example"]);
            table.add       (["count create <name>",        "Create a new counter.",                "!count create dutched"]);
            table.add       (["count remove <name>",        "Remove a counter.",                    "!count remove dutched"]);
            table.add       (["count list",                 "Lists all of the counters.",           "!count list"]);
            table.add       (["count <name>",               "Display a counter.",                   "!count dutched"]);
            table.add       (["count <name> <+1 or -1>",    "Bump up or down a counter.",           "!count dutched +1"]);
            
            this.help = table.toSendableString;
            super(options);
            
            HelpPlugin.helpInfo[this] = this.help;

            setTimer(30.minutes, (){super.storage.save;}, true);
        }

        @Command("count")
        void onCount(CommandEvent e)
        {
            auto msg        = e.msg;
            auto user       = msg.author;
            auto guild      = msg.guild;
            auto command    = (e.args.length == 0) ? "@@DEFAULT@@" : e.args[0];

            super.sealBot.deleter.queue(msg, 15.seconds, false, false);
            void showHelp()
            {
                super.sealBot.deleter.queue(msg.reply(this.help), 
                                            30.seconds);
            }

            switch(command)
            {
                case "create":
                    if(e.args.length < 2)
                    {
                        showHelp();
                        return;
                    }

                    auto name = e.args[1];
                    if(super.storage.has(name))
                    {
                        super.sealBot.deleter.queue(msg.replyf("The counter '%s' already exists.", name),
                                                    15.seconds);
                    }
                    else
                    {
                        super.storage.set(name, Json(0));
                        super.sealBot.deleter.queue(msg.replyf("The great <@%s> has gifted us the counter called '%s'.",
                                                               user.id, name),
                                                    15.seconds);
                    }
                    break;

                case "remove":
                    if(e.args.length < 2)
                    {
                        showHelp();
                        return;
                    }

                    if(!(guild.getPermissions(user.id) & Permissions.ADMINISTRATOR))
                    {
                        super.sealBot.deleter.queue(msg.replyf("Sorry <@%s>, you must be an admin to remove a counter.",
                                                               user.id),
                                                    15.seconds);
                        return;
                    }

                    auto name = e.args[1];
                    if(!super.storage.has(name))
                    {
                        super.sealBot.deleter.queue(msg.replyf("Sorry <@%s>, I don't have a counter named '%s'.",
                                                               user.id, name),
                                                    15.seconds);
                        return;
                    }

                    super.storage.obj.remove(name);
                    super.sealBot.deleter.queue(msg.replyf("The heathen <@%s> dared to remove the counter called '%s'!",
                                                           user.id, name),
                                                15.seconds);
                    break;

                case "list":
                    auto counters = super.storage.obj.get!(Json[string]);
                    auto buffer   = new MessageTable();
                    buffer.setHeader(["Name", "Value"]);
                    
                    foreach(k, v; counters)
                        buffer.add([k, v.get!int.to!string]);
                    
                    super.sealBot.deleter.queue(e.msg.reply(buffer.toSendableString),
                                                1.minutes);
                    break;

                default:
                    if(e.args.length < 1)
                    {
                        showHelp();
                        return;
                    }

                    auto name = e.args[0];

                    if(e.args.length == 2)
                    {
                        int change = 0;

                             if(e.args[1] == "+1") change = 1;
                        else if(e.args[1] == "-1") change = -1;
                        else
                        {
                            super.sealBot.deleter.queue(e.msg.replyf("<@%s>, please use +1 or -1, not '%s'.",
                                                                     user.id, e.args[1]),
                                                        15.seconds);
                        }

                        if(!super.storage.has(name))
                        {
                            super.sealBot.deleter.queue(e.msg.replyf("Sorry <@%s>, there is no counter named '%s'.",
                                                                     user.id, name),
                                                        15.seconds);
                        }

                        super.storage.set(name, Json(super.storage.get!int(name) + change));
                    }

                    if(super.storage.has(name))
                    {
                        super.sealBot.deleter.queue(e.msg.replyf("The counter '%s' is currently at %s",
                                                                 name, super.storage.get!int(name)),
                                                    15.seconds);
                    }
                    else // Little annoyed about reusing this else statement a couple lines above ;_;
                    {
                        super.sealBot.deleter.queue(e.msg.replyf("Sorry <@%s>, there is no counter named '%s'.",
                                                                 user.id, name),
                                                    15.seconds);
                    }
                    break;
            }
        }

        override string name()
        {
            return "Counter";
        }
    }
}
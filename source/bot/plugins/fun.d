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
    static immutable string CAT_API_KEY = "CAT_API_KEY";

    public
    {
        string help;

        this()
        {
            // Setup plugin
            auto options      = new PluginOptions();
            options.useConfig = true;

            auto table = new MessageTable();
            table.setHeader (["Command",    "Description",                  "Example"]);
            table.add       (["cat [gif]",  "Get a random cat image/gif.",  "!cat, or !cat gif"]);

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

        override string name()
        {
            return "FunAPIs";
        }
    }
}
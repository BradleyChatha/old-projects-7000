module bot.plugins.music;

private
{
    import bot.core.autodeleter, bot.core.bot;
    import dscord.core, dscord.voice.youtubedl;
    import vibe.d;
    import dcad.types;
}

class MusicBot : Plugin
{
    public
    {
        const string API_KEY = "GOOGLE_API_KEY";
        string       help;
        VoiceClient  client;
        Playlist     playlist;

        void checkPlaying()
        {
            if(this.client is null) return;

            if(!this.client.playing)
                this.client.play(this.playlist);
        }

        Channel userVoiceChannel(Guild guild, User user) 
        {
            auto state = guild.voiceStates.pick(s => s.userID == user.id);
            if (!state) return null;
            return state.channel;
        }

        override void unload(Bot bot)
        {
            if(this.client !is null)
                this.client.disconnect(false);

            super.unload(bot);
        }

        this()
        {
            auto options       = new PluginOptions();
            options.useStorage = true;
            options.useConfig  = true;
            
            auto table = new MessageTable();
            table.setHeader (["Command",                    "Description",                                          "Example"]);
            table.setHeader (["play [query/youtube_url]",   "Searchs for/downloads a youtube video, and plays it.", "!play Boku no pico happiness"]);
            table.setHeader (["summon",                     "Summons the bot into a voice channel.",                "!summon"]);

            this.help = table.toSendableString;
            super(options);

            HelpPlugin.helpInfo[this] = this.help;

            this.playlist = new Playlist(new SimplePlaylistProvider([]));
        }

        @Command("summon")
        void onSummon(CommandEvent e)
        {
            import std.algorithm;

            auto channel = this.userVoiceChannel(e.msg.guild, e.msg.author);
            if(channel is null || !channel.voice)
            {
                super.sealBot.deleter.queue(e.msg.reply("Unable to join voice channel."), 15.seconds);
                return;
            }

            this.client = channel.joinVoice();
            this.client.connect();
            this.checkPlaying();
        }

        @Command("play")
        void onPlay(CommandEvent e)
        {
            import std.string : join;

            // Helper stuff
            auto seal = super.sealBot;
            void showHelp()
            {
                auto msg = e.msg.reply(this.help);
                seal.deleter.queue(msg, 30.seconds);
            }

            seal.deleter.queue(e.msg, 10.seconds);

            // No args = No function
            if(e.args.length == 0)
            {
                showHelp();
                return;
            }

            // Load the audio.
            DCAPlayable audio;
            auto        param = e.args.join(" ");
            if(param.isURLEncoded)
                audio = new DCAPlayable(this.cacheVideo(param));
            else
            {
                auto video = YoutubeVideo.makeQuery(param, this.apiKey)[0];
                audio = new DCAPlayable(this.cacheVideo(video.watchUrl));
            }

            // Then add it to the playlist.
            (cast(SimplePlaylistProvider)this.playlist.provider).add(audio);
            this.checkPlaying();
        }

        /++
         + Reads the API key from the config.
         + 
         + Returns:
         +  The api key given via the config, or an empty string if the key doesn't exist.
         + ++/
        @property
        string apiKey()
        {
            return super.config.get!string(API_KEY, "");
        }

        override string name()
        {
            return "MusicBot";
        }

        /++
         + ++/
        DCAFile cacheVideo(string url)
        {
            import std.path   : buildPath, exists, getcwd;
            import std.stdio  : File;
            import std.string : split;

            enforce(url.isURLEncoded, "Bad URL: " ~ url);

            auto id   = url.split("=")[$-1];
            auto path = buildPath(getcwd, super.storageDirectoryPath, id ~ ".dca");

            logf("Video path = %s", path);
            if(path.exists)
            {
                logf("Getting cached version of video: %s", id);
                return new DCAFile(File(path, "r"));
            }
            else
            {
                logf("Downloading and caching video: %s", id);

                import std.process : spawnShell;
                spawnShell("youtube-dl -v -r 3.0M -f bestaudio -o - " ~ url ~ 
                           " | ffmpeg -i pipe:0 -f s16le -ar 48000 -ac 2 pipe:1 -vol 100" ~
                           " | dcad --output " ~ path);

                return new DCAFile(File(path, "r"));
            }
        }
    }
}

/++
 + A wrapper around data about a youtube video, recieved via a search query.
 + ++/
struct YoutubeVideo
{
    /++
     + Information about a video's thumbnail
     + ++/
    struct Thumbnail
    {
        /// The URL to the thumbnail.
        string url;

        /// The width of the thumbnail.
        uint width;

        /// The height of the thumbnail.
        uint height;

        this(Json json)
        {
            this.url    = json["url"].get!string;
            this.width  = json["width"].get!int;
            this.height = json["height"].get!int;
        }
    }

    public
    {
        /// The ID of the video. This is used to get a URL to watch the video.
        string id;

        /// The video's title.
        string title;

        /// The description of the video.
        string description;

        /// The default thumbnail for the video
        Thumbnail defaultImage;

        /// The medium thumbnail for the video
        Thumbnail mediumImage;

        /// The large thumbnail for the video
        Thumbnail largeImage;

        static YoutubeVideo[] makeQuery(string query, string apiKey)
        {
            import std.string : replace;
            YoutubeVideo[] videos;

            // Format the URL
            auto url  = "https://www.googleapis.com/youtube/v3/search?";
            url      ~= "part=snippet";
            url      ~= "&safeSearch=none";
            url      ~= "&type=video";
            url      ~= format("&key=%s", apiKey);
            url      ~= format("&q=%s", query.replace(" ", "+"));

            // Then make the request
            requestHTTP(url,
                (scope HTTPClientRequest req)
                {
                    req.method = HTTPMethod.GET;
                },
                (scope HTTPClientResponse res)
                {
                    // Parse the response as Json
                    auto contents = res.bodyReader.readAllUTF8();
                    auto json     = parseJson(contents);

                    // First, check to see if we got the right response back
                    auto response = json["kind"].get!string;
                    enforce(response == "youtube#searchListResponse",
                            format("Expecting response of kind 'youtube#searchListResponse', not '%s'", response));

                    // Next go through all of the items returned from the query, and create everything needed.
                    json = json["items"];
                    foreach(item; json)
                    {
                        YoutubeVideo video;

                        auto snippet        = item["snippet"];
                        auto thumbnails     = snippet["thumbnails"];
                        video.id            = item["id"]["videoId"].get!string;
                        video.defaultImage  = Thumbnail(thumbnails["default"]);
                        video.mediumImage   = Thumbnail(thumbnails["medium"]);
                        video.largeImage    = Thumbnail(thumbnails["high"]);
                        video.title         = snippet["title"].get!string;
                        video.description   = snippet["description"].get!string;

                        videos ~= video;
                    }
                });

            return videos;
        }

        /++
         + Returns:
         +  A URL that can be used to watch the youtube video.
         + ++/
        @property @safe
        string watchUrl()
        {
            return format("https://www.youtube.com/watch?v=%s", this.id);
        }
    }
}
module bot.plugins.test;

private
{
    import dscord.core;
}

class TestPlugin : Plugin
{
    private
    {
    }

    public
    {
        this()
        {
            super();
        }

        @Command("test")
        void onTest(CommandEvent event)
        {
            import bot.core.bot;
            auto seal = cast(SealBot)this.bot;

            import dscord.api.routes, vibe.d;
            this.client.api.requestJSON(Route(HTTPMethod.PATCH, "/guilds/%s/members/%s")(event.msg.guild.id, event.msg.author.id), Json(["roles": Json([Json("208617280987201536")])]));
        }
    }
}
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

            seal.deleter.queue(event.msg.channel.sendMessage("This message should delete after 2 seconds."), 2.seconds);
        }
    }
}
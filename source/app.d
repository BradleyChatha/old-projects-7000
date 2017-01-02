import std.stdio;
import vibe.d;
import dscord.core;

void main()
{
    import bot.core.bot;
    import bot.plugins.test, bot.plugins.fun, bot.plugins.music;

    auto seal = new SealBot();
    scope(exit) seal.unload();

    seal.run();
    seal.loadPlugin(new TestPlugin());
    seal.loadPlugin(new MemePlugin());
    seal.loadPlugin(new FunAPIPlugin());
    seal.loadPlugin(new HelpPlugin());
    seal.loadPlugin(new CountPlugin());
    //seal.loadPlugin(new MusicBot());
    runEventLoop();
}

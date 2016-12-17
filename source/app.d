import std.stdio;
import vibe.d;
import dscord.core;

void main()
{
    import bot.core.bot;
    import bot.plugins.test, bot.plugins.fun;

    auto seal = new SealBot();
    scope(exit) seal.unload();

    seal.run();
    seal.loadPlugin(new TestPlugin());
    seal.loadPlugin(new MemePlugin());
    seal.loadPlugin(new FunAPIPlugin());
    seal.loadPlugin(new HelpPlugin());
    runEventLoop();
}

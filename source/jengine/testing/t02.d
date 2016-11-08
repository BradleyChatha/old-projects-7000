module jengine.testing.t02;

import std.experimental.allocator, sfml;
import jengine.core.engine,
       jengine.core.post,
       jengine.core.maths,
       jengine.graphics.renderer,
       jengine.graphics.window;

void t02()
{
    auto window  = new Window("Test 02", Vector2u(860, 720));
    auto texture = Texture.fromFile("assets/textures/TahnBig.png");
    auto sprite  = Sprite.create(texture, Vector2f(0, 0));
    auto view    = window.renderer.view; // Reminder: This is a *copy*. And is also using AutoSharedPointer.
    scope(exit)
    {
        Texture.dispose(texture);
        Sprite.dispose(sprite);
        window.onUninit();
    }

    window.vsync = true;
    window.input.subscribe(sfEvtKeyPressed, 
        (PostOffice po, Mail m)
        {
            auto event = (cast(ValueMail!sfEvent)m).value;

            if(event.key.code == sfKeyLeft)
                sprite.move(Vector2f(-50, 0));
            else if(event.key.code == sfKeyRight)
                sprite.move(Vector2f(50, 0));

            if(event.key.code == sfKeyUp)
                view.move(Vector2f(0, -50));
            else if(event.key.code == sfKeyDown)
                view.move(Vector2f(0, 50));

            if(event.key.code == sfKeyEscape)
            {
                event.type = sfEvtClosed; // Forge a closed event.
                po.mailValue!sfEvent(sfEvtClosed, event);
            }
        });
    window.input.subscribe(sfEvtClosed,
        (PostOffice po, Mail m)
        {
            window.close();
        });

    while(false) // Replace with window.isOpen if this test needs to actually be used.
                 // In the future, when JEngine is put into a library, a sub-package is used for tests like this.
                 // Because the automated test stuff should be just that, "automatic", without any human interaction.
    {
        window.input.processEvents();
        window.renderer.view = view;
        window.renderer.clear(Colour(0xFF, 0xFF, 0xFF, 0xFF));
        window.renderer.render(sprite);
        window.display();
    }
}
module jengine.testing.t01;
import  jengine.graphics.window,
        jengine.core.post, 
        jengine.core.maths,
        jengine.thirdparty;

void t01()
{
    // Unfortunatly, I can't really test Input.processEvents, since it'd require a human.
    // So I'll just have to assume it works properly
    auto window = new Window("Test 01", Vector2u(860, 720));
    auto input  = window.input;
    scope(exit) window.onUninit();

    // There's no point testing to make sure input.events works, since without Input.processEvents,
    // it functions just as a normal PostOffice
    testMouseMoved(input);
    testMouseButtons(input);
    testTitleChange(window);
    testSizeChange(window);
    testVsyncChange(window);
}

private void testMouseMoved(Input input)
{
    SDL_Event event;
    event.type     = SDL_MOUSEMOTION;
    event.motion.x = 200;
    event.motion.y = 400;
    input.mailValue(SDL_MOUSEMOTION, event);
    assert(input.mouse.position == Vector2f(200, 400));
}

private void testMouseButtons(Input input)
{
    auto types = [SDL_BUTTON_LEFT, SDL_BUTTON_RIGHT, SDL_BUTTON_MIDDLE];

    SDL_Event event;
    void sendEvent()
    {
        foreach(type; types)
        {
            event.button.button = type;
            input.mailValue(cast(Mail.MailTypeT)event.type, event);
        }
    }

    event.type = SDL_MOUSEBUTTONDOWN;
    sendEvent();
    assert(input.mouse.leftButtonDown);
    assert(input.mouse.rightButtonDown);
    assert(input.mouse.middleButtonDown);

    event.type = SDL_MOUSEBUTTONUP;
    sendEvent();
    assert(!input.mouse.leftButtonDown);
    assert(!input.mouse.rightButtonDown);
    assert(!input.mouse.middleButtonDown);
}

private void testTitleChange(Window window)
{
    assert(window.title == "Test 01", window.title);
    window.title = "Hello world!";
    assert(window.title == "Hello world!");
}

private void testSizeChange(Window window)
{
    assert(window.size == Vector2u(860, 720));
    window.size = Vector2u(20, 20);
    assert(window.size == Vector2u(20, 20));
}

private void testVsyncChange(Window window)
{
    window.vsync = true;
    assert(window.vsync);
    window.vsync = false;
    assert(!window.vsync);
}
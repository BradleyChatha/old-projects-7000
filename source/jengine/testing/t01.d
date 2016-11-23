module jengine.testing.t01;
version(none):
import  jengine.graphics.window,
        jengine.core.post, 
        jengine.core.maths;

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
    testIsOpen(window);
}

private void testMouseMoved(Input input)
{
    sfEvent event;
    event.type        = sfEvtMouseMoved;
    event.mouseMove.x = 200;
    event.mouseMove.y = 400;
    input.mailValue!sfEvent(sfEvtMouseMoved, event);
    
    assert(input.mouse.position == Vector2f(200, 400));
}

private void testMouseButtons(Input input)
{
    auto types = [sfMouseLeft, sfMouseRight, sfMouseMiddle];

    sfEvent event;
    void sendEvent()
    {
        foreach(type; types)
        {
            event.mouseButton.button = type;
            input.mailValue!sfEvent(cast(Mail.MailTypeT)event.type, event);
        }
    }

    event.type = sfEvtMouseButtonPressed;
    sendEvent();
    assert(input.mouse.leftButtonDown);
    assert(input.mouse.rightButtonDown);
    assert(input.mouse.middleButtonDown);

    event.type = sfEvtMouseButtonReleased;
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

private void testIsOpen(Window window)
{
    assert(window.isOpen);
    window.close();
    assert(!window.isOpen);
}
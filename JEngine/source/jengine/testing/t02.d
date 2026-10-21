module jengine.testing.t02;

import jengine.graphics, jengine.core;

version(none):
void t02()
{
    import std.exception;
    
    // Some strange notes:
    //  The scope(failure) guard in Animation.create doesn't seem to actually trigger the deconstructor with the
    //  call to theAllocator.dispose, but instead of seems to end up calling Animation.sprite...? External bug is my only guess.

    auto tex = Texture.fromFile("assets/textures/TahnSmall.png");
    // Exception if FrameSize is 0 for either X or Y.
    assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(0, 1))));
    assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(1, 0))));
    
    // Exception if FrameArea is not evenly divisible by FrameSize
    assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(2, 2), IntRect(0, 0, 9, 8))));
    assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(2, 2), IntRect(0, 0, 8, 9))));
    assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(2, 2), IntRect(0, 0, 9, 9))));
    
    // Exception if Texture is null
    assertThrown!GraphicsException(Animation.create(null, Animation.FrameInfo(Vector2u(1, 1))));
}
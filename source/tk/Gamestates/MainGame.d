module tk.MainGame;

import std.stdio;
import Common;
import tk.Entities.Player;

class MainGame : GameState
{
    public override
    {
        /++
         + Called whenever this GameState is:
         +  Pushed onto the top of the stack.
         +  Popped off of the top of the stack.
         +  Is on the top of the stack, but another GameState is pushed on top of it.
         + 
         + Parameters:
         +  action = The action that took place.
         + ++/
        void onSwap(SwapAction action)
        {
            // This can be ommitted most of the time. It's just included to show the different SwapActions
            final switch(action)
            {
                case SwapAction.Pop: break;
                case SwapAction.Push: break;
                case SwapAction.Dethroned: break;
                case SwapAction.Throned: writeln("Now in State #1"); break;
            }
        }
        
        /++
         + Called when any data of the component should be loaded.
         + ++/
        void onInit()
        {
            PhysicalWorld.setup();
            PhysicalWorld.add(theAllocator.make!Player, "Player"); // Once you allocate something and add it to the PhysicalWorld, you don't have to bother deallocating it yourself

            super.onInit();
        }
        
        /++
         + Called everytime the component is updated.
         + 
         + Parameters:
         +  gameTime = A reference to the amount of time the last frame took.
         + ++/
        void onUpdate(ref float gameTime)
        {
            PhysicalWorld.onUpdate(gameTime);
        }
        
        /++
         + Called everytime an event is to be processed.
         + 
         + Parameters:
         +  event = The event to process.
         +  handled = Has the event already been handled?
         + 
         + Returns:
         +  $(D true) if $(B event) was handled. $(D false) otherwise.
         + ++/
        bool onEvent(SDL_Event event, bool handled)
        {
            return PhysicalWorld.onEvent(event, handled) || handled;
        }
        
        /++
         + Called when any data of the component should be unloaded.
         + ++/
        void onUninit()
        {
            super.onUninit();

            PhysicalWorld.destroy();
        }
    }
}

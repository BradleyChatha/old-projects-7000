module tk.MainGame;

import std.random;
import std.stdio;
import Common;
import tk.World.Chunk;
import tk.Entities.Player;
import tk.World.Map.ChunkMapGenerator;
import tk.World.Chunks.ChunkHandler;

class MainGame : GameState
{
   // Chunk c;

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
                case SwapAction.Throned: break;
            }
        }
        
        /++
         + Called when any data of the component should be loaded.
         + ++/
        void onInit()
        {
            PhysicalWorld.setup();
            PhysicalWorld.add(theAllocator.make!Player, "Player"); // Once you allocate something and add it to the PhysicalWorld, you don't have to bother deallocating it yourself

            loadTiles();

            ///A test map
           // ChunkMap map = ChunkMapGenerator.generateMap();

            writeln(Tile.maxID);

            //c = new Chunk(Vector2i(0, 0), map);
            ChunkHandler.setup();

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
            auto player = PhysicalWorld.findAs!Player("Player");
            //c.draw();
            ChunkHandler.update(player); // But this still says it's null...
            ChunkHandler.draw();
         
            PhysicalWorld.onUpdate(gameTime);

            //writeln(c.relativePosition(PhysicalWorld.findAs!Player("Player").sprite.position));
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

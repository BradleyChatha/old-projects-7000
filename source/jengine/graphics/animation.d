module jengine.graphics.animation;

private
{
    import std.experimental.allocator, std.experimental.logger;
    import std.typecons : Flag, Yes, No;

    import jengine.core.maths, jengine.core.cache;
    import jengine.graphics.renderer;
}

/++
 + This class is used to create an animated sprite.
 + 
 + Notes:
 +  This class has an `alias this` to its `Animation.sprite` property, allowing it to be used just like a `Sprite`.
 + 
 + Animation_Control:
 +  There are two main methods of controlling the animation.
 +  
 +  The first, and most easiest way, is to provide the animation a non-zero value for `Animation.frameTime`
 +  (see its documentation for details) and then making sure `Animation.onUpdate` is called.
 + 
 +  The second, and more controlled way, is to manually call `Animation.nextFrame`, or mess around with
 +  `Animation.currentFrame` and `Animation.currentRow` to achieve the wanted results. `Animation.onUpdate` is not
 +  needed for this method.
 + 
 + Changing_Rows_And_Frames:
 +  The `Animation` class will only play the frames of the current row.
 + 
 +  To change which row is being used, please change the value of `Animation.currentRow` to whichever row is needed.
 +  
 +  To change which frame of the row is being used, please change the value of `Animation.currentFrame` to whichever
 +  frame is needed.
 + 
 +  Imagine your game had many animated characters, each with their own Idle, Moving, and Jumping animations.
 +  You could specify that the 0th row of frames is for the Idle animation, the 1st row is for Moving, and the 2nd
 +  row is for Jumping. This is the main decision behind why the row being used must be changed manually.
 + ++/
final class Animation : ICacheable
{
    alias sprite this;

    /++
     + Provides all the information needed to extract frames from the texture.
     + ++/
    struct FrameInfo
    {
        /++
         + This is the size of each frame of animation.
         + 
         + For example, a 64x64 texture might contain 4 16x16 frames.
         + ++/
        Vector2u frameSize;

        /++
         + This is the area of the texture that contains all of the animation frames.
         + 
         + Notes:
         +  If this value is `IntRect.empty`, then the entire texture is used.
         + 
         + See_Also:
         +  `Sprite.textureRect`
         + ++/
        IntRect frameArea = IntRect.empty;
    }

    private
    {
        struct TimeInfo
        {
            double elapsed   = 0.0f;
            double frameTime = 0.0f;
        }

        Sprite      _sprite;
        FrameInfo   _info;
        Vector2u    _frameRowCount;   // x = Frames. y = Rows.
        Vector2u    _currentFrameRow; // ^^
        TimeInfo    _time;

        @safe @nogc
        void updateSprite() nothrow
        {
            auto size = this._info.frameSize;
            auto area = this._info.frameArea;
            this.sprite.textureRect = IntRect(area.position.x + (size.x * this.currentFrame),
                                              area.position.y + (size.y * this.currentRow),
                                              size.x,
                                              size.y);
        }
    }

    public
    {
        ~this()
        {
            tracef("[Disposing of Animation with Texture with handle %s]", this.texture.handle);
            if(this._sprite !is null)
                theAllocator.dispose(this._sprite);
        }

        /++
         + Creates a new `Animation`.
         +
         + Exceptions:
         +  $(P `GraphicsException` if `texture` is `null`.)
         +  $(P `GraphicsException` if `info.frameArea.size` isn't evenly divisble by `info.frameSize`)
         +
         + Notes:
         +  $(P `theAllocator` is used to allocate the object.)
         +  $(P A `Sprite` (via `Animation.sprite`, which also has been `alias this`ed to) is used to control
         +      how the animation is rendered, and is used to actually render it.)
         +
         + Params:
         +  texture   = The `Texture` containing the animation frames.
         +  info      = The `Animation.FrameInfo` providing the information needed to extract the animation frames.
         +  frameTime = Please see `Animation.frameTime` for information.
         +
         + Returns:
         +  The newly created `Animation`.
         + ++/
        static Animation create(Texture texture, FrameInfo info, float frameTime = -1.0f)
        {
            import std.exception : enforce;
            import std.format    : format;

            tracef("[Creating new Animation using Texture with handle %s]", texture.handle);
            enforce(texture !is null, new GraphicsException("Attempted to make an Animation using a null Texture."));

            auto anim = theAllocator.make!Animation;
            scope(failure) theAllocator.dispose(anim);

            if(info.frameArea == IntRect.empty)
                info.frameArea.size = Vector2i(texture.size.x, texture.size.y);

            // Tis a bit ugly to look at ;_;
            tracef("[Animation FrameInfo = %s]", info);
            enforce(cast(float)info.frameArea.size.x % cast(float)info.frameSize.x == 0, 
                    new GraphicsException(format("The frameArea's width(%s) is not evenly divisble by the frameSize's width(%s).", 
                                                 info.frameArea.size.x, info.frameSize.x)));

            enforce(cast(float)info.frameArea.size.y % cast(float)info.frameSize.y == 0, 
                    new GraphicsException(format("The frameArea's height(%s) is not evenly divisble by the frameSize's height(%s).", 
                                                 info.frameArea.size.y, info.frameSize.y)));
                        
            anim._sprite        = Sprite.create(texture, Vector2f(0), info.frameArea);
            anim._info          = info;
            anim._frameRowCount = Vector2u(info.frameArea.size.x / info.frameSize.x,
                                           info.frameArea.size.y / info.frameSize.y);
            anim.frameTime      = frameTime;
            anim.updateSprite();

            return anim;
        }

        /++
         + Disposes of and deallocates an `Animation`.
         + 
         + Notes:
         +  `theAllocator` is used to deallocate the animation.
         + 
         + Params:
         +  anim = A reference to the `Animation` to dispose of and deallocate.
         +         If the animation is `null` then nothing happens.
         + ++/
        @trusted
        static void dispose(ref Animation anim)
        {
            if(anim !is null)
            {
                theAllocator.dispose(anim);
                anim = null;
            }
        }

        /++
         + Updates the animation.
         + 
         + This function only needs to be called if `Animation.frameTime` is being used.
         + 
         + Params:
         +  delta  = The amount of time, in seconds, the last frame took.
         +  repeat = See `Animation.nextFrame` for information.
         + ++/
        @safe
        void onUpdate(double delta, Flag!"repeat" repeat = Yes.repeat) nothrow
        {
            // This function is probably a bit slow(slower than it should be, at least).
            if(this._time.frameTime >= 0)
                this._time.elapsed += delta;

            if(this._time.elapsed >= this._time.frameTime)
            {
                while(this._time.elapsed > this._time.frameTime)
                {
                    this._time.elapsed -= this._time.frameTime;
                    this.nextFrame(repeat);
                }

                this._time.elapsed = 0;
            }
        }

        /++
         + Advances the next frame.
         + 
         + If the animation is on the last frame, then it will loop back to the first frame, if `repeat` is `Yes.repeat`.
         + 
         + Params:
         +  repeat = If `Yes.repeat` then the animation will loop.
         +           If `No.repeat`, then once the last frame is reached, it'll stay like that until changed.
         + ++/
        @safe
        void nextFrame(Flag!"repeat" repeat = Yes.repeat) nothrow
        {
            import std.exception : assumeWontThrow;
            if((this.currentFrame + 1) >= this.frameCount)
            {
                if(repeat)
                    assumeWontThrow(this.currentFrame = 0);
            }
            else
                assumeWontThrow(this.currentFrame = this.currentFrame + 1);
        }

        /++
         + Sets the current frame.
         + 
         + Exceptions:
         +  `GraphicsException` if `frame` is >= `Animation.frameCount`.
         + 
         + Params:
         +  frame = The frame to use.
         + ++/
        @property @safe
        void currentFrame(uint frame)
        {
            import std.exception : enforce;
            import std.format;

            enforce(frame < this.frameCount, 
                new GraphicsException(format("Attempted to set the current frame to too high a value(%s). FrameCount = %s", frame, this.frameCount)));
            this._currentFrameRow.x = frame;

            this.updateSprite();
        }

        /++
         + Returns:
         +  The current frame in the current row.
         + ++/
        @property @safe @nogc
        uint currentFrame() nothrow const
        {
            return this._currentFrameRow.x;
        }

        /++
         + Sets the current row.
         + 
         + Exceptions:
         +  `GraphicsException` if `row` is >= `Animation.rowCount`.
         + 
         + Params:
         +  row = The row to use.
         + ++/
        @property @safe
        void currentRow(uint row)
        {
            import std.exception : enforce;
            import std.format;
            
            enforce(row < this.rowCount, 
                new GraphicsException(format("Attempted to set the current row to too high a value(%s). RowCount = %s", row, this.rowCount)));
            this._currentFrameRow.y = row;

            this.updateSprite();
        }

        /++
         + Returns:
         +  The current row.
         + ++/
        @property @safe @nogc
        uint currentRow() nothrow const
        {
            return this._currentFrameRow.y;
        }

        /++
         + Returns:
         +  The amount of frames per row.
         + ++/
        @property @safe @nogc
        uint frameCount() nothrow const
        {
            return this._frameRowCount.x;
        }

        /++
         + Returns:
         +  The amount of rows.
         + ++/
        @property @safe @nogc
        uint rowCount() nothrow const
        {
            return this._frameRowCount.y;
        }

        /++
         + Sets how long, in seconds, each frame of the animation should be shown before the next on is displayed.
         +
         + For example, if the frameTime is `2.0f`, then after 2 seconds the next frame in the row is displayed.
         +
         + If `time` is negative, then the animation won't automatically advance to the next frame.
         +
         + Params:
         +  time = The frame time, in seconds.
         + ++/
        @property @safe @nogc
        void frameTime(double time) nothrow
        {
            if(time < 0)
                this._time.elapsed = 0;

            this._time.frameTime = time;
        }

        /++
         + Returns:
         +  How long, in seconds, each frame of the animation should be shown before the next one is displayed.
         + ++/
        @property @safe @nogc
        double frameTime() nothrow const
        {
            return this._time.frameTime;
        }

        /++
         + This `Sprite` can be used just like usual, except the `Aniamtion` class will make sure its
         + texture is always the current frame of the animation.
         + 
         + Returns:
         +  The `Sprite` being used by the `Animation`.
         + ++/
        @property @safe @nogc
        inout(Sprite) sprite() nothrow inout
        out(output)
        {
            assert(output !is null, "The sprite is null for some reason. (Future me, fix it)");
        }
        body
        {
            return this._sprite;
        }
    }
}
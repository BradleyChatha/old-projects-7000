using SFML.System;

namespace Game.Engine
{
    /// <summary>
    /// Keeps track of the Frame Per Seconds and the delta time.
    /// </summary>
    public static class FPSCounter
    {
        /*
         * Public 
         */
        
        /// <summary>
        /// Sets up everything for useage.
        /// </summary>
        public static void Init()
        {
            FrameCounter = 0;
            PreviousFrame = 0;
            NewTime = 0;
            OldTime = 0;
            FrameTimer = new Clock();
            DeltaTimer = new Clock();
        }

        /// <summary>
        /// Updates the framerate, and delta time once per frame.
        /// </summary>
        public static void Update()
        {
            float TimeSinceStart = FrameTimer.ElapsedTime.AsSeconds();

            OldTime = NewTime;
            NewTime = (uint)DeltaTimer.ElapsedTime.AsMilliseconds();

            if (TimeSinceStart >= 1)
            {
                FrameTimer.Restart();
                PreviousFrame = FrameCounter;
                FrameCounter = 0;
            }            

            FrameCounter++;
        }

        /// <summary>
        /// Returns the amount of Frames which passed the previous second.
        /// </summary>
        public static uint FrameCount
        {
            get { return PreviousFrame; }
        }

        public static float DeltaTime
        {
            get
            {
                float dt = ((float)NewTime - (float)OldTime) / 1000.0f;
                return dt;
            }
        }

        /*
         * Private
         */
        private static uint FrameCounter;
        private static uint PreviousFrame;
        private static uint NewTime, OldTime;
        private static Clock FrameTimer, DeltaTimer;
    }
}

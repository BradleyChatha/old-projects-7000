using SFML.Graphics;
using SFML.System;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Asteroids
{
    public static class AsteroidManager
    {
        public static void Init()
        {
            Asteroids = new List<Asteroid>();
            Counter = 1;
        }

        public static void Update(Player Plr)
        {
            Random Rand = new Random();

            if (Counter % 15 == 0)
            {
                bool Skip = false;

                float X = (float)Rand.Next(0, 1280);
                float Y = (float)Rand.Next(0, 720);

                for (int i = 0; i < Asteroids.Count; i++)
                {
                    if (Asteroids[i] == null)
                    {
                        Asteroids[i] = new Asteroid(new Vector2f(X, Y));
                        Skip = true;
                        break;
                    }
                }

                if (!Skip)
                {
                    Asteroids.Add(new Asteroid(new Vector2f(X, Y)));
                }                
            }

            Counter += 1;

            for (int i = 0; i < Asteroids.Count; i++)
            {
                if (Asteroids[i] == null)
                    continue;

                if(!Asteroids[i].IsAlive)
                {
                    Asteroids[i] = null;
                    continue;
                }

                Asteroids[i].Update(Plr);
            }
        }

        public static void Draw(RenderWindow Wnd)
        {
            for(int i = 0; i < Asteroids.Count; i++)
            {
                if (Asteroids[i] == null)
                    continue;

                Asteroids[i].Draw(Wnd);
            }
        }

        private static List<Asteroid> Asteroids;
        private static int Counter;
    }
}

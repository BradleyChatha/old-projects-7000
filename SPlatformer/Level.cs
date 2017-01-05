using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.System;
using SFML.Graphics;

namespace SPlatformer
{
    class LevelException : Exception
    {
        public LevelException(string Message)
        {
            throw new Exception(Message);
        }
    }

    public class Level
    {
        public Level(string Map)
        {
            try
            {
                this.MapContents = File.ReadAllLines(Map);
            }
            catch(Exception e)
            {
                if (Controller.InDepthExceptions)
                    throw new LevelException($"{e.Message} Failed to load map.");
                else
                    throw new LevelException($"Failed to load in {Map}");
            }

            this.LevelTiles = new List<Tile>();
            this.ProcessMap();
        }

        public void Draw(RenderWindow Wnd)
        {
            foreach(Tile T in this.LevelTiles)
            {
                T.Draw(Wnd);
            }
        }

        /// <summary>
        /// The 'downward' pull on the player, in this world.
        /// </summary>
        public float Gravity
        {
            get { return 9.8f;  }
        }

        private void ProcessMap()
        {
            if (this.MapContents.Length == 0)
                throw new LevelException("Failed to load map. Map is empty");

            foreach(string Line in this.MapContents)
            {
                int CurrentIndex = 0;
                string[] LineComponents = new string[3];
                string CurrentComponent = "";

                for(int i = 0; i < Line.Length; i++)
                {
                    if(Line[i] == ' ')
                    {
                        LineComponents[CurrentIndex] = CurrentComponent;
                        CurrentIndex++;
                        CurrentComponent = "";
                    }
                    else
                        CurrentComponent += Line[i];

                    Console.WriteLine(CurrentComponent);
                }

                LineComponents[CurrentIndex] = CurrentComponent;

                TileID ID = (TileID)int.Parse(LineComponents[0]);
                float XPosition = float.Parse(LineComponents[1]);
                float YPosition = float.Parse(LineComponents[2]);

                Tile T;

                switch(ID)
                {
                    case TileID.Platform:
                        T = new Platform();
                        T.SetPositionByCell(new Vector2f(XPosition, YPosition));
                    break;

                    default:
                        throw new LevelException($"Unkown Tile ID {ID}");
                }   
                                             
                LevelTiles.Add(T);
            }
        }

        private string[] MapContents;
        private List<Tile> LevelTiles;
    }
}

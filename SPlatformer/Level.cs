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
        
        public void Update(float dt, Player Plr)
        {
            for (int i = 0; i < this.LevelTiles.Count; i++)
                this.LevelTiles[i].Update(dt, Plr);
        }

        public Tile GetTileByCell(Vector2i Cell)
        {
            foreach(Tile T in this.LevelTiles)
            {
                if (T.Cell == Cell)
                    return T;
            }

            return null;
        }

        private void ProcessMap()
        {
            if (this.MapContents.Length == 0)
                throw new LevelException("Failed to load map. Map is empty");

            foreach(string Line in this.MapContents)
            {
                string[] LineComponents = Line.Split(' ');
                TileID ID = TileID.TotalTiles;
                float XPosition = 0;
                float YPosition = 0;

                ///Ignore comments
                if (LineComponents[0].Contains("#"))
                    continue;

                try
                {
                    ID = (TileID)int.Parse(LineComponents[0]);
                    XPosition = float.Parse(LineComponents[1]);
                    YPosition = float.Parse(LineComponents[2]);
                }
                catch(Exception e)
                {
                    if (Controller.InDepthExceptions)
                        throw new LevelException($"{e.Message} Failed to read level map.");
                    else
                        throw new LevelException("Failed to read in the level map.");
                }

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
        public List<Tile> LevelTiles; // Temporarily public
    }
}

using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using SFML.System;
using System.Xml;

namespace Game.Engine
{
    class Map
    {
        public Map(string MapFile)
        {
            this.MapProps = new List<Prop>();
            this.MapLocation = MapFile;

            Logger.Log(LogLevel.Debug, $"Read {Path.GetFileName(MapFile)} into memory.");
        }

        public void Update()
        {
            for (int i = 0; i < this.MapProps.Count; i++)
            {
                if(this.MapProps[i].DoesUpdate)
                    this.MapProps[i].Update();
            }
        }

        public void Draw(DrawWindow Wnd)
        {
            for(int i = 0; i < this.MapProps.Count; i++)
                Wnd.WindowHandle.Draw(this.MapProps[i].DrawableSprite);
        }

        public void LoadMap(DrawWindow WindhowHandle)
        {
            using (XmlReader MapReader = XmlReader.Create(this.MapLocation))
            {
                MapReader.MoveToContent();

                while(MapReader.Read())
                {
                    if (MapReader.Name == "StaticProp")
                    {
                        float XLocation = float.Parse(MapReader.GetAttribute("x"));
                        float YLocation = float.Parse(MapReader.GetAttribute("y"));
                        string Path = MapReader.GetAttribute("src");

                        this.MapProps.Add(new Prop(Path, new Vector2f(XLocation, YLocation)));
                    }
                    if(MapReader.Name == "Background")
                    {
                        int GridWidth = int.Parse(MapReader.GetAttribute("width"));
                        int GridHeight = int.Parse(MapReader.GetAttribute("height"));
                        string BackgroundPath = MapReader.GetAttribute("src");

                        this.MapProps.Insert(0, new StaticProp(BackgroundPath, new Vector2f(0, 0)));
                    }
                }

                Logger.Log(LogLevel.Info, $"Loaded the map {this.MapLocation}");
            }
        }

        public Prop GetPropAtLocation(Vector2f Position)
        {
            for(int i = 0; i < this.MapProps.Count; i++)
            {
                if(this.MapProps[i].IsPropAtLocation(Position))
                    return this.MapProps[i];
            }

            return null;
        }

        private List<Prop> MapProps;
        private string MapLocation;
    }
}

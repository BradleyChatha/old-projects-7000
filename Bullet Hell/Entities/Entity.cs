using System;
using System.Xml;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.System;

namespace Bullet_Hell.Entities
{
    public enum FirePattern
    {
        Circular = 0,
        Line,
        Single
    }

    public class Entity
    {
        public Entity(string DataSheet)
        {
            this.LoadXML(DataSheet);

            /*
            this.EntityTexture = new Texture(TexturePath);
            this.EntitySprite = new Sprite(this.EntityTexture);
            
            this.BulletTexture = new Texture(BulletPath);
            this.BulletSprite = new Sprite(this.BulletTexture);*/
        }

        public void Update()
        {

        }

        public void Draw(RenderWindow Window)
        {
            Window.Draw(this.EntitySprite);

            if (this.BulletSprite != null)
                Window.Draw(this.BulletSprite);
        }

        public void LoadXML(string DataSheet)
        {
            using (XmlTextReader Reader = new XmlTextReader(DataSheet))
            {
                this.HasBullets = false;
                this.TexturePath = "";
                this.BulletPath = "";
                
                while (Reader.Read())
                {
                    switch (Reader.NodeType)
                    {
                        case XmlNodeType.Element:
                            if(Reader.Name == "Entity")
                            {
                                this.EntityName = Reader.GetAttribute("Name");

                                Console.WriteLine($"Entity name is {this.EntityName}");
                            }
                            else if (Reader.Name == "Entity-Texture")
                            {
                                Reader.Read();
                                this.TexturePath = Reader.Value;
                                Console.WriteLine($"{this.EntityName}'s texture is located at {this.TexturePath}");
                            }
                            else if (Reader.Name == "Entity-Health")
                            {
                                Reader.Read();
                                bool T = int.TryParse(Reader.Value, out this.MaxHealth);
                                this.CurrentHealth = this.MaxHealth;
                                Console.WriteLine($"{this.EntityName}'s maximum health is {this.MaxHealth}");
                            }
                            else if (Reader.Name == "Entity-Bullets")
                            {
                                Reader.Read();
                                this.BulletPath = Reader.Value;
                                Console.WriteLine($"{this.EntityName}'s bullet texture is located at {this.TexturePath}");
                            }
                            else if(Reader.Name == "Entity-Fire-Rate")
                            {
                                string Pattern = Reader.GetAttribute("Pattern");

                                switch (Pattern)
                                {
                                    case "Circular":
                                        this.FirePattern = FirePattern.Circular;
                                        break;
                                    case "Line":
                                        this.FirePattern = FirePattern.Line;
                                        break;
                                    case "Single":
                                        this.FirePattern = FirePattern.Single;
                                        break;                                   
                                }
                                
                                ///Read in as N bullets per second
                                ///Convert to "how often to fire". 
                                Reader.Read();
                                float.TryParse(Reader.Value, out float Temp);
                                this.FireSpeed = Temp / 60;
                                Console.WriteLine($"{this.EntityName}'s has a firing pattern of {this.FirePattern} and a firing speed of {this.FireSpeed}");
                            }
                            break;
                    }
                }
            }
        }


        private Texture BulletTexture;
        private Texture EntityTexture;
        private Sprite BulletSprite;
        private Sprite EntitySprite;

        private string EntityName;

        private string TexturePath;
        private string BulletPath;
        private bool HasBullets;

        private float FireSpeed;
        private FirePattern FirePattern;

        private int MaxHealth;
        private int CurrentHealth;
    }
}

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

        private void LoadXML(string DataSheet)
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
                            ///The root node.
                            if(Reader.Name == "Entity")
                            {
                                ///What the name of the entity is.
                                this.EntityName = Reader.GetAttribute("Name");
                                ///How fast the entity can move.
                                float.TryParse(Reader.GetAttribute("Speed"), out this.MovementSpeed);

                                Console.WriteLine($"Entity name is {this.EntityName} and travels at a speed of {this.MovementSpeed}px/s");
                            }
                            ///The path to the texture for the entity
                            else if (Reader.Name == "Entity-Texture")
                            {
                                Reader.Read();
                                this.TexturePath = Reader.Value;
                                Console.WriteLine($"{this.EntityName}'s texture is located at {this.TexturePath}");
                            }
                            ///How much health the entity has.
                            else if (Reader.Name == "Entity-Health")
                            {
                                Reader.Read();
                                bool T = int.TryParse(Reader.Value, out this.MaxHealth);
                                this.CurrentHealth = this.MaxHealth;
                                Console.WriteLine($"{this.EntityName}'s maximum health is {this.MaxHealth}");
                            }
                            ///The path to the entity's bullet path, is this isn't present it is presumed to be a kamikaze
                            else if (Reader.Name == "Entity-Bullets")
                            {
                                Reader.Read();
                                this.BulletPath = Reader.Value;
                                this.HasBullets = true;
                                Console.WriteLine($"{this.EntityName}'s bullet texture is located at {this.TexturePath}");
                            }
                            ///How fast the bullets are shot
                            else if(Reader.Name == "Entity-Fire-Rate")
                            {
                                ///How the bullets are fired.
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
                                Reader.Read();
                                float.TryParse(Reader.Value, out float Temp);
                                this.FireSpeed = Temp;
                                Console.WriteLine($"{this.EntityName}'s has a firing pattern of {this.FirePattern} and a firing speed of {this.FireSpeed}");
                            }
                            ///How much damage is dealt to the player on hit
                            else if(Reader.Name == "Entity-Bullet-Damage")
                            {
                                Reader.Read();
                                float.TryParse(Reader.Value, out this.Damage);
                                Console.WriteLine($"{this.EntityName} does {this.Damage} per shot");
                            }                           
                            ///Where the bullets are shot from on the entity.
                            else if(Reader.Name == "Entity-Fire-Position")
                            {
                                ///X coord in the texture rect
                                float.TryParse(Reader.GetAttribute("X"), out float XPos);
                                ///Y coord in the texture rect
                                float.TryParse(Reader.GetAttribute("Y"), out float YPos);

                                ///How close the entity needs to be to the player in order to fire.
                                if (this.HasBullets)
                                    float.TryParse(Reader.GetAttribute("Distance"), out this.FireDistance);
                                this.FirePosition = new Vector2f(XPos, YPos);

                                Console.WriteLine($"Bullets will spawn at {this.FirePosition} on {this.EntityName}. {this.EntityName} needs to be with in {this.FireDistance}px to be able to fire.");
                            } 
                            break;
                    }
                }
            }
        }

        public float BulletDamage
        {
            get { return this.Damage; }
        }

        private Texture BulletTexture;
        private Texture EntityTexture;
        private Sprite BulletSprite;
        private Sprite EntitySprite;

        private string EntityName;
        
        private string TexturePath;
        private string BulletPath;
        private bool HasBullets;

        private float Damage;
        private float FireSpeed;
        private FirePattern FirePattern;
        private Vector2f FirePosition;
        private float FireDistance;

        private int MaxHealth;
        private int CurrentHealth;
        private float MovementSpeed;
    }
}

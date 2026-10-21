using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.Window;
using SFML.System;

namespace Bullet_Hell.Scene
{    
    public class ParallaxBackground
    {
        public ParallaxBackground(string BottomLayer = "", string MiddleLayer = "", string TopLayer = "")
        {
            if(BottomLayer != "")
            {
                this.BottomTexture = new Texture(BottomLayer);
                this.BottomSprite = new Sprite(BottomTexture);
            }

            if(MiddleLayer != "")
            {
                this.MiddleTexture = new Texture(MiddleLayer);
                this.MiddleSprite = new Sprite(this.MiddleTexture);
            }

            if(TopLayer != "")
            {
                this.MiddleTexture = new Texture(MiddleLayer);
                this.MiddleSprite = new Sprite(this.MiddleTexture);
            }
        }

        public void Update(float dt)
        {

        }

        private Texture BottomTexture;
        private Texture MiddleTexture;
        private Texture TopTexture;

        private Sprite BottomSprite;
        private Sprite MiddleSprite;
        private Sprite TopSprite;
    }
}

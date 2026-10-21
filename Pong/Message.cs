using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.Window;
using SFML.System;

namespace Pong
{
    public static class Message
    {
        public static void Init()
        {
            MessageFont = new Font("LiberationMono-Regular.ttf");

            MessageText = new Text();

            MessageText.CharacterSize = 32;
            MessageText.Color = Color.Black;
            MessageText.Font = MessageFont;
        }
        
        public static void SetMessage(string Message)
        {
            MessageText.DisplayedString = Message;
            MessageText.Position = new Vector2f(400 - ((MessageText.CharacterSize * Message.Length) / 2), 100);
        }

        public static void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(MessageText);
        }

        private static Font MessageFont;
        private static Text MessageText;
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using SFML.System;

namespace Game.Engine
{
    class VectorMaths
    {
        public static Vector2f Lerp(Vector2f Pos1, Vector2f Pos2, float Percentage)
        {
            float LerpX = (1 - Percentage) * Pos1.X + Percentage * Pos2.X;
            float LerpY = (1 - Percentage) * Pos1.Y + Percentage * Pos2.Y;

            return new Vector2f(LerpX, LerpY);
        }
    }
}

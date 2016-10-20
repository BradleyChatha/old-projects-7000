import std.stdio;

import GameEngine.GameEngine;

void main(string[] Args)
{
    Core core = new Core();
    Window window = new Window("GLFWWindow", 800, 600);
    Input input = new Input(window.GetWindow());
    Shader shader = new Shader(window.GetWindow());

    shader.CompileShadersFromString(
        "
            uniform float Scale;

            void main(void)
            {
                vec4 a = gl_Vertex;     
                a.x = a.x * Scale;     
                a.y = a.y * Scale;     

                gl_Position = gl_ModelViewProjectionMatrix * a; 
            }
        ",
        "
            uniform vec4 uColor;

            void main (void) 
            { 
                gl_FragColor = uColor; 
            }
        "
    );

    shader.SetUniformFloat("Scale", 10.0f);

    Colour col = Colour(1, 0, 0, 1);

    while(window.IsOpen())
    {
        if(input.GetKeyPressed(Key.A))
            col = Colour(0, 1, 0, 1);
        if(input.GetKeyPressed(Key.B))
            col = Colour(0, 0, 1, 1);
        if(input.GetKeyPressed(Key.C))
            col = Colour(1, 0, 1, 1);
      
        window.Clear(col);
        window.Draw();
    }
}
///
module GameEngine.Input;

private
{
    import derelict.glfw3.glfw3;
}

/++
+   All of the Key Types
++/
enum Key : int
{
    Zero = GLFW_KEY_0,
	One = GLFW_KEY_1,
	Two = GLFW_KEY_2,
	Three = GLFW_KEY_3,
	Four = GLFW_KEY_4,
	Five = GLFW_KEY_5,
	Six = GLFW_KEY_6,
	Seven = GLFW_KEY_7,
	Eight = GLFW_KEY_8,
	Nine = GLFW_KEY_9,

	A = GLFW_KEY_A,
	B = GLFW_KEY_B,
	C = GLFW_KEY_C,
	D = GLFW_KEY_D,
	E = GLFW_KEY_E,
	F = GLFW_KEY_F,
	G = GLFW_KEY_G,
	H = GLFW_KEY_H,
	I = GLFW_KEY_I,
	J = GLFW_KEY_J,
	K = GLFW_KEY_K,
	L = GLFW_KEY_L,
	M = GLFW_KEY_M,
	N = GLFW_KEY_N,
	O = GLFW_KEY_O,
	P = GLFW_KEY_P,
	Q = GLFW_KEY_Q,
	R = GLFW_KEY_R,
	S = GLFW_KEY_S,
	T = GLFW_KEY_T,
	U = GLFW_KEY_U,
	V = GLFW_KEY_V,
	W = GLFW_KEY_W,
	X = GLFW_KEY_X,
	Y = GLFW_KEY_Y,
	Z = GLFW_KEY_Z,

	LShift = GLFW_KEY_LEFT_SHIFT,
	LControl = GLFW_KEY_LEFT_CONTROL,
	LAlt = GLFW_KEY_LEFT_ALT,
	LArrow = GLFW_KEY_LEFT,
	LBracket = GLFW_KEY_LEFT_BRACKET,

	RShift = GLFW_KEY_RIGHT_SHIFT,
	RControl = GLFW_KEY_RIGHT_CONTROL,
	RAlt = GLFW_KEY_RIGHT_ALT,
	RArrow = GLFW_KEY_RIGHT,
	RBracket = GLFW_KEY_RIGHT_BRACKET,

	Enter = GLFW_KEY_ENTER,
	Period = GLFW_KEY_PERIOD,
	Comma = GLFW_KEY_COMMA,
	Colon = GLFW_KEY_SEMICOLON,
	Space = GLFW_KEY_SPACE,
	Up = GLFW_KEY_UP,
	Down = GLFW_KEY_DOWN,
	Apostrophe = GLFW_KEY_APOSTROPHE,
	Delete = GLFW_KEY_DELETE,
	Backspace = GLFW_KEY_BACKSPACE,
	ForwardSlash = GLFW_KEY_SLASH,
	BackSlash = GLFW_KEY_BACKSLASH,
	Escape = GLFW_KEY_ESCAPE
}

/++
+   Handles all of the input that is given
++/
class Input
{
    /++
    +   Sets the Window pointer and constructs Input Manager.
    ++/
    this(GLFWwindow* window)
    {
        this.Wnd = window;
    }

    /++
    +   Gets whether a Key has been pressed by the user.
    +
    +   Params:
    +       key = The key which is pressed.
    +
    +   Returns:
    +       True = The key was pressed.
    +       False = The key was not pressed.
    ++/
    bool GetKeyPressed(Key key)
    {
        return (glfwGetKey(this.Wnd, key) == GLFW_PRESS);
    }


    /++
    +   Gets whether a Key has been released by the user.
    +
    +   Params:
    +       key = The key which is released.
    +
    +   Returns:
    +       True = The key was released.
    +       False = The key was not released.
    ++/
    bool GetKeyReleased(Key key)
    {
        return (glfwGetKey(this.Wnd, key) == GLFW_RELEASE);
    }

    /++
    +   Gets whether a key was pressed by a user along with the left shift key.
    +
    +   Params:
    +       key = The key which is pressed.
    +
    +   Returns:
    +       True = The key was pressed.
    +       False = The key was not pressed.    
    ++/
    bool GetKeyPressWithShift(Key key)
    {
        return (glfwGetKey(this.Wnd, key) == GLFW_PRESS &&
		    glfwGetKey(this.Wnd, Key.LShift) == GLFW_PRESS);
    }
private:
    GLFWwindow* Wnd;
}
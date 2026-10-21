///Pretty much the same as "module ExampleProgram" in D.
///C++ doesn't have modules because they're rude. C++ modules are going to be C++20, I think...
///As Jasm is slightly changing, I don't know if this is how it can work, but for now it is how I want it.
namespace ExampleProgram;

///Imports another namespace.
///In JASM it translates to "import "std.io.jasm" ".
import std.io;

///This is an example of importing a namespace that was created by the used.
///Note: The 'User' bit isn't a keyword or needed. It simply shows the folder structure /User/Magic.e. 
import User.Magic;

///A user-defined class which is an example of public and private, also shows ctors and returning values.
class Point
{
	///In C++ would be "Point::Point(int x, int y)"
	///In D would be "this(int x, int y)"
	public constructor(var x as int, var y as int)
	{
		X = x;
		Y = y;
	}
	
	///In C++ would be "Point::~Point()"
	///In D would be "~this()"
	public deconstructor()
	{
	}
	
	///Brad called this weird.
	///Just a proof of concept function.
	public GetPointByName(var Name as string) as int
	{
		if(Name == "X")
		{
			return X;
		}
		elif(Name == "Y")
		{
			return Y;
		}
		else
		{
			Console.print("The point " + Name + " does not exsist");
			return -1;
		}
	}
	
	private var X as int;
	private var Y as int;
}

///Weird class just to display how looping words.
class Loop
{
	public constructor(var CanLoop as bool)
	{
		IsLooping = CanLoop;
	}
	
	public deconstructor()
	{
	}
	
	public WhileUpdate() as void
	{
		///While loop, totally not C like *cough*.
		///IsLooping == true
		while(IsLooping)
		{
			Console.print("Meme");
		}
	}
	
	public ForUpdate() as void
	{
		///For loop is C like
		for(var i as int = 0; i < 10; i++)
		{
			Console.print(i);
		}
	}
	
	private var IsLooping as bool;
}

///The class which constains the main function, which JASM looks for.
///Doesn't need to be called entry, just looks for a public main function is all.
class Entry
{
	public main() as void
	{
		var MyNumber as int = 10;
		var MyString as string;
		var MyPoint as Point = new Point(10, -23);
		var FoundPoint as int = MyPoint.GetPointByName("X");
		
		Console.println(MyNumber);
		
		Console.print("Enter your name: ");
		MyString = Console.input();
		Console.println(MyString);
		
		Console.println(FoundPoint);
	}
}
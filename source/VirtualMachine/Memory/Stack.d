module VirtualMachine.Memory.Stack;

import std.array : popBack;

static class Stack
{
    public static void Push(ubyte[] Data)
    {
        MemoryStack ~= Data;
    }

    public static ubyte[] Pop()
    {
        ubyte[] Return = MemoryStack[MemoryStack.length - 1];
        MemoryStack.popBack();
        return Return;
    }

    @property
    public static uint Length()
    {
        return cast(uint)MemoryStack.length;
    }

    @property
    public static bool IsEmpty()
    {
        return (MemoryStack.length == 0);
    }

    private static ubyte[][] MemoryStack;
}
unittest
{
    Stack.Push([1, 2, 3]);
    assert(!Stack.IsEmpty);
    assert(Stack.Length == 1);
    assert(Stack.Pop == [1, 2, 3]);
    assert(Stack.IsEmpty);
}
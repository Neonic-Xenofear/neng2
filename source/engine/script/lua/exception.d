module engine.script.lua.exception;

class StateException : Exception
{
    @safe @nogc pure nothrow this(string msg)
    {
        super(msg);
    }
}
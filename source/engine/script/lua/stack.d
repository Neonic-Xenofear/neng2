module engine.script.lua.stack;

import core.memory;

import derelict.lua.types;
import derelict.lua.functions;
import derelict.lua.functions;
import derelict.lua.lua;

import engine.script.lua.classes : pushInstance;
import engine.script.lua.exception;
import engine.script.lua.state;

import std.stdio;
import std.string;
import std.traits;

package void pushValue(T)(lua_State* L, T value) if(!is(T == struct))
{
  static if(is(T == typeof(null)))
    lua_pushnil(L);
  else static if(is(T == bool))
    lua_pushboolean(L, value);
  else static if(is(T == char))
    lua_pushlstring(L, &value, 1);
  else static if(is(T : lua_Integer))
    lua_pushinteger(L, value);
  else static if(is(T : lua_Number))
    lua_pushnumber(L, value);
  else static if(is(T : const(char)[]))
    lua_pushlstring(L, value.ptr, value.length);
  else static if(is(T : const(char)*))
    lua_pushstring(L, value);
  else static if(is(T == lua_CFunction) && functionLinkage!T == "C")
    lua_pushcfunction(L, value);
  else static if(is(T == class))
  {
    if(value is null)
      lua_pushnil(L);
    else
			pushInstance!T(L, value);
  }
  else
    static assert(false, "Unsupported type being pushed: "~T.stringof~" in stack.d");
}
module engine.script.lua.classes;

import core.memory;

import derelict.lua.types;
import derelict.lua.functions;
import derelict.lua.lua;

import engine.script.attrib;
import engine.script.lua.stack;
import engine.script.lua.state;

import std.stdio;
import std.string;
import std.traits;

/**
 * registerClass - implementation of the state objects class registering feature
 * takes a class, iterates through its members and adds the annotated ones where applicable
 * Params:
 * T = the class to register
 * state = the Lua state wrapper we're using
 */
package void registerClass(T)(State state)
{
  static assert(hasUDA!(T, ScriptExport));

  lua_CFunction x_gc = (lua_State* L)
  {
    GC.removeRoot(lua_touserdata(L, 1));
    return 0;
  };

  lua_State* L = state.state;

  // -------------------------------------------------------------------
  // the top of the stack being the right-most in the following comments
  // -----------------------------------------------------
  // Create a metatable named after the D-class and add some constructors and methods
  // ---------------------------------------------------------------------------------
  luaL_newmetatable(L, getUDAs!(T, ScriptExport)[0].name); // x = {}
  lua_pushvalue(L, -1); // x = {}, x = {} 
  lua_setfield(L, -1, "__index"); // x = {__index = x}
  lua_pushcfunction(L, &newUserdata!(T)); // x = {__index = x}, x_new
  lua_setfield(L, -2, "new"); // x = {__index = x, new = x_new}
  lua_pushcfunction(L, x_gc); // x = {__index = x, new = x_new}, x_gc
  lua_setfield(L, -2, "__gc"); // x = {__index = x, new = x_new, __gc = x_gc}
  lua_pushstring( L, toStringz( T.stringof ) ); // x = {__index = x, new = x_new, __gc = x_gc}, x_nativeClass
  lua_setfield( L, -2, "__nativeClass" ); // x = {__index = x, new = x_new, __gc = x_gc, __nativeClass = x_nativeClass}

  // ---------------------------------
  pushMethods!(T, 0)(L);
  lua_setglobal(L, getUDAs!(T, ScriptExport)[0].name);
}
/// Push an instance of a registered class onto the stack
package void pushInstance(T)(lua_State* L, T instance)
{
  T* ud = cast(T*)lua_newuserdata(L, (void*).sizeof); // ud
  *ud = instance;
  GC.addRoot(ud);
  lua_newtable(L); // ud, { }
  lua_pushcfunction(L, &udIndexMetamethod); // ud, { }, cindxmethod
  lua_setfield(L, -2, "__index"); // ud, { __index=cindxmethod }
  lua_getglobal(L, getUDAs!(T, ScriptExport)[0].name); // ud, { __index=cindxmethod }, tmetatable
  if(cast(bool)lua_isnil(L, -1)) // Make sure that the metatable for the class exists
    luaL_error(L, toStringz("Error: class "~T.stringof~" has not been registered"));
  lua_setfield(L, -2, "__class"); // ud, { __index=cindxmethod, __class=tmetatable }
  lua_pushstring( L, toStringz( T.stringof ) );
  lua_setfield( L, -2, "__nativeClass" );
  pushLightUds!(T, 0)(L, *ud); // ud, { }, { __index=cindxmethod, __class=tmetatable, lightuds }
  lua_setmetatable(L, -2); // ud( ^ )
}
/**
 * fillArgs - take a parameter tuple and fill it in with values from the lua stack
 * constructors are only matched by the number of arguments they take
 * Params:
 * Del = a delegate
 * index = the index of the argument we're dealing with
 * forMethod = changes how far the lua argument index offset starts
 * L = the lua state
 * params = the parameter tuple
 */
private void fillArgs(Del, int index, bool forMethod=true)(lua_State* L, ref Parameters!Del params)
{
  alias ParamList = Parameters!Del;
  static if(ParamList.length > 0)
  {
    const int luaStartingArgIndex = 1; // index 1 is the self, index 2 is our first arugment that we want to deal with
    //static if(forMethod)
    int luaOffsetArg = index+luaStartingArgIndex+(forMethod ? 1 : 0);
    //else
    //  const int luaOffsetArg = index+luaStartingArgIndex;
    static if(is(typeof(params[index]) == int))
    {
      params[index] = luaL_checkint(L, luaOffsetArg);
    }
    else static if(is(typeof(params[index]) == string))
    {
      params[index] = cast(string)fromStringz(luaL_checkstring(L, luaOffsetArg));
    }
    else static if(is(typeof(params[index]) == float) || is(typeof(params[index]) == double))
    {
      params[index] = luaL_checknumber(L, luaOffsetArg);
    }
    else static if(is(typeof(params[index]) == bool))
    {
      params[index] = cast(bool)luaL_checkboolean(L, luaOffsetArg);
    }
    else static if(isPointer!(typeof(params[index]))) {
      params[index] = cast(typeof(params[index]))lua_topointer(L, luaOffsetArg);
    }
    else static if(is(typeof(params[index]) == class)) {
      // We have to try two things:
      // 1) check with lua to see if the name of T.stringof exists as a metatable
      if(cast(bool)lua_isuserdata(L, luaOffsetArg)) {
        lua_getglobal(L, typeof(params[index]).stringof);
        if(!lua_isnil(L, -1)) {
          lua_pop(L, 1);
          params[index] = cast(typeof(params[index]))lua_touserdata(L, luaOffsetArg);
        }
      }
      else if(cast(bool)lua_islightuserdata(L, luaOffsetArg)) {
        params[index] = cast(typeof(params[index]))lua_topointer(L, luaOffsetArg);
      }
      else if(lua_isnil(L, luaOffsetArg)) {
        params[index] = null;
      }
      else {
        luaL_error(L, "Expected a user data/D class instance or light userdata or nil");
        throw new Exception("Lua argument exception");
      }
    }
    static if(index+1 < ParamList.length)
      fillArgs!(Del, index+1, forMethod)(L, params);
  }
}
/**
 * methodWrapper - the closure by which methods are called
 * Params:
 * Del = the method we're handling
 * Class = the class which the method resides in
 * index = the derivedMembers index of the class we're on
 * L = lua state
 * Returns:
 * int, as per the lua c function api
 */
private extern(C) int methodWrapper(Del, Class, uint index)(lua_State* L)
{
  alias Args = ParameterTypeTuple!Del;

  static assert ((variadicFunctionStyle!Del != Variadic.d && variadicFunctionStyle!Del != Variadic.c),
		"Non-typesafe variadic functions are not supported.");

  immutable int top = lua_gettop(L);

  static if (variadicFunctionStyle!Del == Variadic.typesafe)
		enum requiredArgs = Args.length;
	else
		enum requiredArgs = Args.length + 1;
  
  if(top < requiredArgs)
  {
    writeln("Argument error in D method wrapper");
    return 0;
  }
  void* sD = lua_touserdata( L, 1 );
  if ( sD is null ) {
    writeln( "Something invalid" );
    return 0;
  }

  Class self = *cast(Class*)sD;
  if ( !self ) {
    return 0;
  }
  
  Del func;
  func.ptr = cast(void*)self;
  func.funcptr = cast(typeof(func.funcptr))lua_touserdata(L, lua_upvalueindex(1));

  Parameters!Del typeObj;
  fillArgs!(Del, 0, true)(L, typeObj);

  static if(hasUDA!(mixin("Class."~__traits(allMembers, Class)[index]), ScriptExport))
  {
    alias RT = ReturnType!Del;
    static if(!is(RT == void))
    {
      RT returnValue = func(typeObj);
      enum luaUda = getUDAs!(mixin("Class."~__traits(allMembers, Class)[index]), ScriptExport)[0];
      static if(luaUda.rtype == RetType.lightud)
      {
        static if(luaUda.submember != "")
        {
          lua_pushlightuserdata(L, mixin("returnValue."~luaUda.submember));
          return 1;
        }
      }
      else
      {
        pushValue(L, returnValue);
        return 1;
      }
    }
    else
    {
      func(typeObj);
      return 0;
    }
  }
  
  assert(0, "Somehow reached a spot in methodWrapper that shouldn't be possible");
}
/**
 * extapolateThis - meant to figure out which constructor to call by the number of arguments
 * being passed by lua
 * Params:
 * T = the class
 * index = the which constructor from derivedMembers we're examining
 * L = lua State
 * argc = the number of args
 * Returns:
 * instance returned by new T(params)
 */
private T extrapolateThis(T, uint index)(lua_State* L, uint argc)
{
  static assert(hasUDA!(T, ScriptExport));
  static if(
    __traits(getProtection, __traits(getOverloads, T, "__ctor")[index]) == "public" &&
    hasUDA!(__traits(getOverloads, T, "__ctor")[index], ScriptExport))
  {
    enum luaUda = getUDAs!(__traits(getOverloads, T, "__ctor")[index], ScriptExport)[0];
    static if(luaUda.type == MethodType.ctor)
    {
      Parameters!(__traits(getOverloads, T, "__ctor")[index]) args;
      if(argc == args.length) {
        fillArgs!(typeof(__traits(getOverloads, T, "__ctor")[index]), 0, false)(L, args);
        import engine.scene.base : CNode;
        import engine.core.engine.engine : getEngine;

        T res = new T( args );
        if ( CNode node = cast( CNode )res ) {
          getEngine().sceneTree.addScriptNode( node );
        }

        return res;
      }
    }
  }
  static if(index+1 < __traits(getOverloads, T, "__ctor").length)
    return extrapolateThis!(T, index+1)(L, argc);
  assert(false, "We shouldn't end up here");
}
/// Method used for instantiating userdata
private extern(C) int newUserdata(T)(lua_State* L)
{
  immutable int nargs = lua_gettop(L);
  alias thisOverloads = typeof(__traits(getOverloads, T, "__ctor"));

  pushInstance!T(L, extrapolateThis!(T, 0)(L, nargs)); //new T());
  return 1;
}
/// Method for garbage collecting userdata
private extern(C) int gcUserdata(lua_State* L)
{
  GC.removeRoot(lua_touserdata(L, 1));
  return 0;
}

/// User data index methamethod
private extern(C) int udIndexMetamethod(lua_State* L)
{
  lua_getmetatable(L, 1);
  lua_getfield(L, -1, luaL_checkstring(L, 2));
  if(cast(bool)lua_isnil(L, -1))
  {
    lua_pop(L, 1);
    lua_getfield(L, -1, "__class");
    lua_getfield(L, -1, luaL_checkstring(L, 2));
    lua_remove(L, -2);
  }
  return 1;
}

/// Iterate through classes methods and add them to class table
private void pushMethods(T, uint index)(lua_State* L)
{ //derivedMembers
  static assert(hasUDA!(T, ScriptExport));
  static if(__traits(allMembers, T)[index] != "this" &&
    __traits(allMembers, T)[index] != "iterateAllSerializables" &&
    __traits( getProtection, __traits( getMember, T, __traits( allMembers, T )[index] ) ) == "public" &&
    hasUDA!(mixin("T."~__traits(allMembers, T)[index]), ScriptExport)) 
  {
    // Get the lua uda struct associated with this member function
    enum luaUda = getUDAs!(mixin("T."~__traits(allMembers, T)[index]), ScriptExport)[0];
    static if(luaUda.type == MethodType.method)
    {
      alias DelType = typeof(mixin("&T.init."~__traits(allMembers, T)[index]));
      lua_pushlightuserdata(L, &mixin("T."~__traits(allMembers,T)[index])); // x = { ... }, &T.member
      lua_pushcclosure(L, &methodWrapper!(DelType, T, index), 1); // x = { ... }, closure { &T.member }
      lua_setfield(L, -2, toStringz(luaUda.name)); // x = { ..., fn = closure { &T.member } }
    }
  }
  static if(index+1 < __traits(allMembers, T).length)
    pushMethods!(T, index+1)(L);
}

/// T refers to a de-referenced instance
private void pushLightUds(T, uint index)(lua_State* L, T instance)
{
  static assert(hasUDA!(T, ScriptExport));
  static if(__traits(derivedMembers, T).length > 1 &&
    __traits(derivedMembers, T)[index] != "this" &&
    __traits(derivedMembers, T)[index] != "iterateAllSerializables" &&
    __traits( getProtection, __traits( getMember, T, __traits( allMembers, T )[index] ) ) == "public" &&
    hasUDA!(mixin("T."~__traits(derivedMembers, T)[index]), ScriptExport))
  {
    // Get the lua uda struct associated with this member function
    enum luaUda = getUDAs!(mixin("T."~__traits(derivedMembers, T)[index]), ScriptExport)[0];
    static if(luaUda.memtype == MemberType.lightud)
    {
      static if(luaUda.submember != "")
      {
          auto lightuserdata = mixin("instance."~__traits(derivedMembers, T)[index]~"."~luaUda.submember);
          if(lightuserdata is null)
            writeln("Error: provided light userdata "~luaUda.name~" is null");
          lua_pushlightuserdata(L, lightuserdata);
      }
      else
        lua_pushlightuserdata(L, &mixin("instance."~__traits(derivedMembers, T)[index]));
      lua_setfield(L, -2, toStringz(luaUda.name));
    }
  }
  static if(index+1 < __traits(derivedMembers, T).length)
    pushLightUds!(T, index+1)(L, instance);
}

@ScriptExport("MyClass")
private class MyClass
{
  @ScriptExport("", MethodType.ctor)
  public this(string name)
  {
    myname = name;
  }
  private string myname;

  @ScriptExport("getName", MethodType.method, "", RetType.str)
  public string getName()
  {
    return myname;
  }
}

public:
unittest
{
  import derelict.lua.lua;
  DerelictLua.load( "../libs/lua5.3.0.dll" );
  State state = new State();
  state.openLibs();
  state.registerClass!MyClass;
  state.getGlobal("MyClass");
  lua_State* L = state.state;
  assert(cast(bool)lua_isnil(L, -1) == false);
  assert(lua_type(L, -1) == LUA_TTABLE);
  lua_getfield(L, -1, "new");
  assert(lua_type(L, -1) == LUA_TFUNCTION);
  state.push("jean");
  assert(lua_pcall(L, 1, 1, 0) == 0, fromStringz(lua_tostring(L, -1)));
  assert(lua_type(L, -1) == LUA_TUSERDATA);
  lua_getfield(L, -1, "getName");
  assert(cast(bool)lua_isnil(L, -1) == false);
  assert(lua_type(L, -1) == LUA_TFUNCTION);
  lua_insert(L, -2); // Swap getName to be below the userdata object
  assert(lua_pcall(L, 1, 1, 0) == 0);
  assert(fromStringz(luaL_checkstring(L, -1)) == "jean");
  lua_pop(L, 1);
  state.doString("assert(MyClass.new('bill'):getName() == 'bill')");
}
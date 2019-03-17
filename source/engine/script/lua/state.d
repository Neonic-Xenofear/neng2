module engine.script.lua.state;

import std.string;
import std.uuid;
import std.traits;

import derelict.lua.types;
import derelict.lua.functions;
import derelict.lua.functions;
import derelict.lua.lua;

import engine.core.ext_data;
import engine.script.attrib;
import engine.script.lua.classes : registerClassType = registerClass;
import engine.script.lua.stack;
import engine.script.lua.exception;
import engine.app.logger;
import std.conv;

struct SScriptClassInfo {
    string scriptName;
    string str;
    UUID objUUID;

    void updateUUID( UUID newUUID ) {
        objUUID = newUUID;
        str = newUUID.toString();
    }
}

class State
{
    @safe this() {             
        import engine.core.utils;
        version( Windows ) {
            ( () @trusted => DerelictLua.load( appExePathAndNorm( "../../libs/win/lua5.3.0.dll" ) ) )();
        } else {
            ( () @trusted => DerelictLua.load( appExePathAndNorm( "../../libs/linux/liblua.so.5.3" ) ) )();
        }
        luastate = ( () @trusted => luaL_newstate() )();
        if(luastate is null)
            throw new Exception("Failed to instantiate luastate");
        is_owner = true;
        openLibs(); 
    }
    package @safe this(lua_State* L)
    {
        if(L is null)
            throw new StateException("Passing null to State()");
        is_owner = false;
        luastate = L;
    }
    @safe this(State other)
    {
        if(other is null)
            throw new StateException("Cannot copy null state");
        this(other.state);
    }
    @safe ~this()
    {
        if(is_owner && !(state is null))
            (() @trusted => lua_close(state))();
    }
    /**
     * Load a file for execution
     * Params:
     * file, non null string
     */
    @safe void doFile(string file)
    {
        if(file is null)
            throw new StateException("Cannot pass null to doFile");
        if((() @trusted => luaL_dofile(state, toStringz(file)))() != 0)
            printError(this);
    }

    @safe void doString(string line)
    {
        if(line is null)
            throw new StateException("Cannot pass null to doString");
        if((() @trusted => luaL_dostring(state, toStringz(line)))() != 0)
            printError(this);
    }
    /**
     * This function does not add a suffix - it is left to the user
     * this way the user can add .lua or .moon suffix to their path
     */
    @safe void addPath(string path)
    {
        doString("package.path = package.path .. ';' .. '"~path~"/?.lua'");
    }
    /**
     * On windows this functions adds the dll suffix to your path. On linux/mac it will at so
     */
    @safe void addCPath(string path)
    {
        version(Windows) {
            doString("package.cpath = package.cpath .. ';"~path~"/?.dll'");
        }
        version(MinGW) {
            doString("package.cpath = package.cpath .. ';"~path~"/?.dll'");
        }
        // linux/mac
        else {
            doString("package.cpath = package.cpath .. ';"~path~"/?.so'");
        }
    }
    @safe void openLibs()
    {
        (() @trusted => luaL_openlibs(state))();
    }
    void require(string filename)
    {
        if(requireFile(this, filename) != 0)
            throw new Exception("Lua related exception");
    }
    @trusted void registerClass(T)()
    {
        registerClassType!T(this);
        log.info( "Registered script class: " ~ T.stringof );
    }
    @trusted void unregisterClass( T )() {
        assert( hasUDA!( T, ScriptExport ) );
        lua_pushnil( state );
        lua_setglobal( state, getUDAs!( T, ScriptExport )[0].name );
        log.info( "Unregistered script class: " ~ T.stringof );
    }
    @trusted void push(T)(T value)
    {
        pushValue!T(state, value);
    }
    @safe void pop(int index)
    {
        (() @trusted => lua_pop(state, index))();
    }
    @safe void setGlobal(string name)
    {
        if(!(name is null))
            (() @trusted => lua_setglobal(state, toStringz(name)))();
        else
            throw new StateException("Lua state or name for global to be set were null");
    }
    @safe void getGlobal(string name)
    {
        if(!(name is null))
            (() @trusted => lua_getglobal(state, toStringz(name)))();
        else
            throw new StateException("Lua state or name for global to get were null");
    }
    @safe bool isNil(int index)
    {
        return (() @trusted => cast(bool)lua_isnil(state, index))();
    }
    @property
    @safe @nogc lua_State* state() nothrow
    {
        return luastate;
    }

    void callClassFunction( Args... )( string className, string func, CExtData objectData, Args args ) {
        if ( !objectData ) {  //Check for invalid object
            return;
        }

        getGlobal( className );
        if ( lua_isnil( state, -1 ) ) {
            lua_pop( state, -1 );
            return;
        }

        SScriptClassInfo info = objectData.as!SScriptClassInfo;

        //Get object from registry by UUID
        lua_getfield( state, LUA_REGISTRYINDEX, toStringz( info.str ) );
        if ( lua_isnil( state, -1 ) ) {
            lua_pop( state, -1 );
            return;
        }

        //Get object field
        lua_getfield( state, -1, toStringz( func ) );
        if ( !lua_isfunction( state, -1 ) ) {
            lua_pop( state, -1 );
            return;
        }

        //Push instance to up of stack
        lua_pushvalue( state, -2 );

        //Push other arguments to stack
        foreach( arg; args ) {
            push( arg );
        }

        lua_pcall( state, args.length + 1, 0, 0 );    //args.length + 1 == object instance + arguments
    }

    void getNewScriptObject( string className, CExtData data ) {
        getGlobal( className );
        if ( lua_isnil( state, -1 ) ) {
            printError( this );
            return;
        }

        lua_getfield( state, -1, "new" );
        if ( !lua_isfunction( state, -1 ) ) {
            lua_pop( state, -1 );
            return;
        }

        lua_pcall( state, 0, 1, 0 );    //Create new object instance
        if ( lua_isnil( state, -1 ) ) {
            lua_pop( state, -1 );
            return;
        }

        SScriptClassInfo info;
        info.updateUUID( randomUUID() );    //Generate object UUID

        lua_pushvalue( state, -2 ); //Set object instance to stack top
        lua_setfield( state, LUA_REGISTRYINDEX, toStringz( info.str ) ); //Set object registry index

        lua_pop( state, -1 ); //Pop object from stack
        lua_pop( state, -1 ); //Pop global table from stack

        objects ~= info;
        data = info;
    }

    string getNativeClassName( string className ) {
        import std.conv : to;
        getGlobal( className );
        if ( lua_isnil( state, -1 ) ) {
            return "";
        }

        lua_getfield( state, -1, "__nativeClass" );
        if ( lua_isnil( state, -1 ) ) {
            return "";
        }

        string resName = to!string( lua_tostring( state, -1 ) );
        lua_pop( state, -1 );

        return resName;
    }

    private lua_State* luastate;
    bool is_owner;
    SScriptClassInfo[] objects;
}

import std.stdio : writeln;
package @safe void printError(State state)
{
    writeln((() @trusted => fromStringz(luaL_checkstring(state.state, -1)))());
    state.pop(1);
}
private int requireFile (State state, string name) {
    state.getGlobal("require");
    state.push(name);
    return report(state, (() @trusted => lua_pcall(state.state, 1, 1, 0))());
}
private @safe int report(State state, int status)
{
	if(status != 0 && !state.isNil(-1))
        printError(state);
	return status;
}

unittest {
    import std.exception;
    import derelict.lua.lua;
    DerelictLua.load( "../../libs/lua5.3.0.dll" );

    assertThrown!StateException(new State(cast(lua_State*)null), "State object with null lua_State* should have failed");
    assertThrown!StateException(new State(cast(State)null), "State object with null State should have failed");
    auto state = new State();
    assert(!(state is null), "state should not be null");
    assert(!(state.state is null), "state.state should not be null");
    assertThrown!StateException(state.setGlobal(null), "setGlobal should have thrown because null passed to arg 0");
    assertThrown!StateException(state.getGlobal(null), "getGlobal should have thrown because null passed to arg 0");
    assertNotThrown!StateException(state.getGlobal("barry"), "getGlobal shouldn't have thrown when trying to get non existant global: barry");
    assert(state.isNil(-1), "The top of the stack should have been nil after trying to get non existant global");
    state.pop(1);
    state.push("Hola");
    assert(lua_type(state.state, -1) == LUA_TSTRING, "Lua type should have been a string");
    state.pop(1);
}
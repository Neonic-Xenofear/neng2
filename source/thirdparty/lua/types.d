/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.lua.types;

//luaconf.h
alias LUA_INT32 = int;
alias LUAI_UMEM = size_t;
alias LUAI_MEM = ptrdiff_t;
alias LUAI_UACNUMBER = double;

enum LUA_NUMBER_SCAN = "%lf";
enum LUA_NUMBER_FMT = "%.14g";
enum LUAI_MAXSTACK = 1000000;
enum LUA_EXTRASPACE = (void*).sizeof;

//lua.h
// The minimum version of Lua with which this binding is compatible.
enum LUA_VERSION_MAJOR ="5";
enum LUA_VERSION_MINOR ="3";
enum LUA_VERSION_NUM = 503;
enum LUA_VERSION_RELEASE = "0";

enum LUA_VERSION = "Lua " ~ LUA_VERSION_MAJOR ~ "." ~ LUA_VERSION_MINOR;
enum LUA_RELEASE = LUA_VERSION ~ "." ~ LUA_VERSION_RELEASE;
enum LUA_COPYRIGHT = LUA_RELEASE ~ "  Copyright (C) 1994-2012 Lua.org, PUC-Rio";
enum LUA_AUTHORS = "R. Ierusalimschy, L. H. de Figueiredo, W. Celes";

enum LUA_SIGNATURE = "\x1bLua";
enum LUA_MULTRET = -1;

enum LUA_REGISTRYINDEX = -LUAI_MAXSTACK - 1000;

int lua_upvalueindex(int i) nothrow {
    return LUA_REGISTRYINDEX - i;
}

enum {
    LUA_OK = 0,
    LUA_YIELD = 1,
    LUA_ERRRUN = 2,
    LUA_ERRSYNTAX = 3,
    LUA_ERRMEM = 4,
    LUA_ERRGCMM = 5,
    LUA_ERRERR = 6,
}

struct lua_State;

enum {
    LUA_TNONE = -1,
    LUA_TNIL = 0,
    LUA_TBOOLEAN = 1,
    LUA_TLIGHTUSERDATA = 2,
    LUA_TNUMBER = 3,
    LUA_TSTRING = 4,
    LUA_TTABLE = 5,
    LUA_TFUNCTION = 6,
    LUA_TUSERDATA = 7,
    LUA_TTHREAD = 8,
    LUA_NUMTAGS = 9,

    LUA_MINSTACK = 20,

    LUA_RIDX_MAINTHREAD = 1,
    LUA_RIDX_GLOBALS = 2,
    LUA_RIDX_LAST = LUA_RIDX_GLOBALS,
}

alias lua_Number = double;
alias lua_Integer = ptrdiff_t;
alias lua_Unsigned = uint;
alias lua_KContext = ptrdiff_t;
alias LUA_NUMBER = lua_Number;
alias LUA_INTEGER = lua_Integer;
alias LUA_UNSIGNED = lua_Unsigned;
alias LUA_KCONTEXT = lua_KContext;

extern(C) {
    alias lua_CFunction = int function(lua_State*);
    alias lua_KFunction = int function(lua_State*, int, lua_KContext);
    alias lua_Reader = const(char)* function(lua_State*, void*, size_t*);
    alias lua_Writer = int function(lua_State*, const(void)*, size_t, void*);
    alias lua_Alloc = void* function(void*, void*, size_t, size_t);
}

enum {
    LUA_OPADD = 0,
    LUA_OPSUB = 1,
    LUA_OPMUL = 2,
    LUA_OPMOD = 3,
    LUA_OPPOW = 4,
    LUA_OPDIV = 5,
    LUA_OPIDIV = 6,
    LUA_OPBAND = 7,
    LUA_OPBOR = 8,
    LUA_OPBXOR = 9,
    LUA_OPSHL = 10,
    LUA_OPSHR = 11,
    LUA_OPUNM = 12,
    LUA_OPBNOT = 13,

    LUA_OPEQ = 0,
    LUA_OPLT = 1,
    LUA_OPLE = 2,

    LUA_GCSTOP = 0,
    LUA_GCRESTART = 1,
    LUA_GCCOLLECT = 2,
    LUA_GCCOUNT = 3,
    LUA_GCCOUNTB = 4,
    LUA_GCSTEP = 5,
    LUA_GCSETPAUSE = 6,
    LUA_GCSETSTEPMUL = 7,
    LUA_GCISRUNNING = 9,

    LUA_HOOKCALL = 0,
    LUA_HOOKRET = 1,
    LUA_HOOKLINE = 2,
    LUA_HOOKCOUNT = 3,
    LUA_HOOKTAILCALL = 4,

    LUA_MASKCALL = 1 << LUA_HOOKCALL,
    LUA_MASKRET = 1 << LUA_HOOKRET,
    LUA_MASKLINE = 1 << LUA_HOOKLINE,
    LUA_MASKCOUNT = 1 << LUA_HOOKCOUNT,
}

struct lua_Debug;

extern(C) nothrow alias lua_Hook  = void function(lua_State*, lua_Debug*);

//lauxlib.h
struct luaL_Reg {
    const(char)* name;
    lua_CFunction func;
}

enum LUAL_NUMSIZES = (lua_Integer.sizeof * 16) + lua_Number.sizeof;

enum LUA_NOREF = -2;
enum int LUA_REFNIL = -1;

struct luaL_Buffer {
    char* b;
    size_t size;
    size_t n;
    lua_State* L;
    char[] initb;
}

struct luaL_Stream;

//lualib.h
enum : string {
    LUA_COLIBNAME = "coroutine",
    LUA_TABLIBNAME = "table",
    LUA_IOLIBNAME = "io",
    LUA_OSLIBNAME = "os",
    LUA_STRLIBNAME = "string",
    LUA_UTF8LIBNAME = "utf8",
    LUA_BITLIBNAME = "bit32",
    LUA_MATHLIBNAME = "math",
    LUA_DBLIBNAME = "debug",
    LUA_LOADLIBNAME = "package",
}

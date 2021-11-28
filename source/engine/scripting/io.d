module engine.scripting.io;
import bindbc.lua;
import std.string;

private {
    ubyte[] compiledCode;
    int _kmLuaDump(lua_State* state, const(void)* p, size_t sz, void* ud) nothrow {
        compiledCode ~= cast(ubyte[])p[0..sz].dup;
        return 0;
    }
}

/**
    Does a standalone compile of the specified source.
*/
ubyte[] kmLuaCompile(string source) {
    compiledCode.length = 0;
    lua_State* cstate = luaL_newstate();
    luaL_loadstring(cstate, source.toStringz);
    lua_pcall(cstate, 0, LUA_MULTRET, 0);
    lua_dump(cstate, &_kmLuaDump, null, 0);

    // Close the compiler state
    lua_close(cstate);
    return compiledCode;
}

/**
    Compile lua in an existing state
*/
ubyte[] kmLuaCompile(lua_State* state) {
    compiledCode.length = 0;
    lua_dump(state, &_kmLuaDump, null, 0);
    return compiledCode;
}

/**
    Loads a string source in to the VM
*/
void kmLuaLoad(lua_State* state, string source) {
    luaL_loadstring(state, source.toStringz);
}

/**
    Loads a bytecode blob in to the VM
*/
void kmLuaLoad(lua_State* state, string scriptName, ubyte[] bytecode) {
    luaL_loadbuffer(state, cast(const(char)*)bytecode.ptr, bytecode.length, scriptName.toStringz);
}

/**
    Apply the loading of a script module
*/
void kmLuaLoadApply(lua_State* state) {
    lua_pcall(state, 0, LUA_MULTRET, 0);
}
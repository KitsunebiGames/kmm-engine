module engine.scripting.state;
public import bindbc.lua;

/**
    Creates a new lua state
*/
lua_State* kmLuaNewState() {
    auto state = luaL_newstate();

    // These should be relatively safe
    luaopen_math(state);
    luaopen_utf8(state);
    luaopen_table(state);
    luaopen_coroutine(state);
    return state;
}

/**
    Creates a new thread of execution
    Make sure to bind it to something or it may get garbage collected.
*/
lua_State* kmLuaNewThread(lua_State* state) {
    return lua_newthread(state);
}

/**
    Destroys a lua state
*/
void kmLuaDestroy(lua_State* state) {
    lua_close(state);
}

/**
    Create a persistent reference to a Lua object
*/
int kmLuaRef(lua_State* state) {
    return luaL_ref(state, LUA_REGISTRYINDEX);
}

/**
    Dereference a reference
*/
void kmLuaDeref(lua_State* state, int r) {
    lua_rawgeti(state, LUA_REGISTRYINDEX, r);
}

/**
    Release a persistent reference to a Lua object
*/
void kmLuaRelease(lua_State* state, int refId) {
    return luaL_unref(state, LUA_REGISTRYINDEX, refId);
}
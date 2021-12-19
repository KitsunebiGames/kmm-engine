module engine.scripting.env;
import engine;
import bindbc.lua;
import std.string;
import std.array;

/**
    Sets the execution environment for a loaded script
*/
void kmLuaSetEnv(lua_State* state, int offset) {
    lua_setupvalue(state, -offset, 1);
}

/**
    Set a pointer in an existing table
*/
void kmLuaSetPtr(lua_State* state, string name, void* entityPtr) {
    lua_pushstring(state, name.toStringz);
    lua_pushlightuserdata(state, entityPtr);
    lua_settable(state, -3);
}

/**
    Pushes an entity function on to the stack
    Returns true if it succeded, false otherwise.
*/
bool kmLuaGetEntityEnvFunc(lua_State* state, string env, uint entityId, string funcSig) {
    // Push our environment on to the stack
    if (lua_getglobal(state, env.toStringz) != LUA_TTABLE) {
        lua_pop(state, 1);
        return false;
    }

    // Get the table
    lua_pushinteger(state, entityId);
    if (!lua_gettable(state, -2) == LUA_TTABLE) {
        lua_pop(state, 2);
        return false;
    }

    // Get the function
    lua_pushstring(state, funcSig.toStringz);
    if (lua_gettable(state, -2) != LUA_TFUNCTION) {
        lua_pop(state, 3);
        return false;
    }

    return true;
}

/**
    Creates a reference to a environment entity function
*/
int kmLuaRefEntityEnvFunc(lua_State* state, string env, uint entityId, string funcSig) {
    if (kmLuaGetEntityEnvFunc(state, env, entityId, funcSig)) {
        int id = luaL_ref(state, LUA_REGISTRYINDEX);
        lua_pop(state, 2);
        return id;
    }
    return LUA_REFNIL;
}

/**
    Destroys the entity inside of an environment
*/
void kmLuaDestroyEntityEnv(lua_State* state, string env, uint entityId) {

    // Push our environment on to the stack
    if (lua_getglobal(state, env.toStringz) != LUA_TTABLE) return;

    // Attempts to push table inside of environment to the stack
    lua_pushinteger(state, entityId);

    // If the table exists, destroy it
    if (lua_gettable(state, -2) != LUA_TNIL) {
        // We don't want to pop from our table, but rather remove it.
        // Thefore we pop it immediately after we find it
        lua_pop(state, 1);

        // The key is popped during gettable, push it again
        lua_pushinteger(state, entityId);            // key
        lua_pushnil(state);                          // value

        // Set value of key to nil
        lua_rawset(state, -3);
    } else lua_pop(state, 1); // table is still not needed.
    
    // Pop our environment off the stack
    lua_pop(state, 1);
}

/**
    Ensures an environment exists in the Lua VM
*/
void kmLuaEnsureEnv(lua_State* state, string env) {
    if (lua_getglobal(state, env.toStringz) != LUA_TTABLE) {

        // Environment wasn't a table, force it to be one
        lua_pop(state, 1);
        
        lua_newtable(state);
        lua_setglobal(state, env.toStringz);
        return;
    }

    // Make sure we pop it here too, to avoid polluting the stack.
    lua_pop(state, 1);
}

/**
    Sets the environment for an entity
    An entity pointer for the environment table is also set.
*/
void kmLuaSetEntityEnv(bool createOnly = false)(lua_State* state, string env, size_t entityId, void* entityPtr) {

    // Make sure the environment exists
    kmLuaEnsureEnv(state, env);

    // Push the environment on to the stack
    lua_getglobal(state, env.toStringz);


    // Attempts to push table inside of environment to the stack
    lua_pushinteger(state, entityId);
    switch(lua_gettable(state, -2)) {
        case LUA_TTABLE: break;
        case LUA_TNIL:
            lua_pop(state, 1);

            // Push new table and set it as the table for the environment
            lua_pushinteger(state, entityId);            // key
            lua_newtable(state);                         // value

            // Set entityName in env to a new table
            lua_rawset(state, -3);

            // Only need to set this pointer on initial configuration
            lua_pushinteger(state, entityId);            // key
            if (lua_gettable(state, -2) == LUA_TTABLE) { // table
                kmLuaSetPtr(state, "_ptr", entityPtr);
            }
    
            break;
        
        default:

            // Pop environment off stack!
            lua_pop(state, 1);
            throw new Exception("Could not overwrite non-table element!");
    }
    
    static if (!createOnly) {
        // Set our environment
        kmLuaSetEnv(state, 3);

        // Pop our environment off the stack
        // NOTE: kmLuaSetEnv pops the entity off the stack.
        lua_pop(state, 1);
    } else {

        // Pop environment and entity off the stack
        lua_pop(state, 2);
    }
}
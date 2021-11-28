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
    Destroys the entity inside of an environment
*/
void kmLuaDestroyEntityEnv(lua_State* state, string env, string entityName) {

    // Push our environment on to the stack
    if (lua_getglobal(state, env.toStringz) != LUA_TTABLE) return;

    // Attempts to push table inside of environment to the stack
    lua_pushstring(state, entityName.toStringz);

    // If the table exists, destroy it
    if (lua_gettable(state, -2) != LUA_TNIL) {
        // We don't want to pop from our table, but rather remove it.
        // Thefore we pop it immediately after we find it
        lua_pop(state, 1);

        // The key is popped during gettable, push it again
        lua_pushstring(state, entityName.toStringz); // key
        lua_pushnil(state);                          // value

        // Set value of key to nil
        lua_rawset(state, -3);
    } else lua_pop(state, 1); // table is still not needed.
    
    // Pop our environment off the stack
    lua_pop(state, 1);
}

/**
    Sets the environment for an entity
    An entity pointer for the environment table is also set.
*/
void kmLuaSetEntityEnv(lua_State* state, string env, string entityName, void* entityPtr) {

    // Push our environment on to the stack
    if (lua_getglobal(state, env.toStringz) != LUA_TTABLE) {

        // Environment wasn't a table, force it to be one
        lua_pop(state, 1);
        
        lua_newtable(state);
        lua_setglobal(state, env.toStringz);

        // Push the environment for reals.
        lua_getglobal(state, env.toStringz);
    }


    // Attempts to push table inside of environment to the stack
    lua_pushstring(state, entityName.toStringz);
    switch(lua_gettable(state, -2)) {
        case LUA_TNIL:
            lua_pop(state, 1);

            // Push new table and set it as the table for the environment
            lua_pushstring(state, entityName.toStringz); // key
            lua_newtable(state);                         // value

            // Set entityName in env to a new table
            lua_rawset(state, -3);

            // Only need to set this pointer on initial configuration
            lua_pushstring(state, entityName.toStringz); // key
            if (lua_gettable(state, -2) == LUA_TTABLE) { // table
                kmLuaSetPtr(state, "_ptr", entityPtr);
            }
    
            break;

        case LUA_TTABLE: break;
        
        default:

            // Pop environment off stack!
            lua_pop(state, 1);
            throw new Exception("Entity was taken!");
    }
    
    // Set our environment
    kmLuaSetEnv(state, 3);


    // Pop our environment off the stack
    // NOTE: kmLuaSetEnv pops the entity off the stack.
    lua_pop(state, 1);
}
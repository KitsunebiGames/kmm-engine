module engine.scripting.tools;
import engine;
import bindbc.lua;
import std.json;
import std.string;
import std.conv;
import std.format;

/**
    Dumps the stack to string
*/
string kmLuaDumpStack(lua_State* state) {
    string elm;

    int top = lua_gettop(state);
    foreach(i; 1..top+1) {
        elm ~= "%s %s = ".format(i, cast(string)luaL_typename(state, i).fromStringz);

        switch(lua_type(state, i)) {
            case LUA_TNUMBER:
                elm ~= "%s\n".format(lua_tonumber(state,i));
                break;
            case LUA_TSTRING:
                elm ~= "%s\n".format(cast(string)lua_tostring(state,i).fromStringz);
                break;
            case LUA_TBOOLEAN:
                elm ~= "%s\n".format(cast(bool)lua_toboolean(state, i));
                break;
            case LUA_TNIL:
                elm ~= "nil\n";
                break;
            default:
                elm ~= "0x%x\n".format(lua_topointer(state,i));
                break;
        }
    }

    return elm;
}

/**
    Dumps all tables of _G
*/
JSONValue kmLuaDumpGlobalTable(lua_State* state, string table) {
    lua_getglobal(state, table.toStringz);
    JSONValue value = JSONValue.init;
    _kmLuaDumpTablesRecurse(state, value);
    return value;
}

private
void _kmLuaDumpTablesRecurse(lua_State* state, ref JSONValue value) {
    lua_pushnil(state);

    while(lua_next(state, -2) != 0) {
        string key;
        switch (lua_type(state, -2)) {
            case LUA_TSTRING:
                key = cast(string)lua_tostring(state, -2).fromStringz;
                break;

            case LUA_TNUMBER:
                key = lua_tonumber(state, -2).to!string;
                break;
            default: return; // skip keys we can't parse
        }

        switch(lua_type(state, -1)) {
            case LUA_TNUMBER:
                value[key] = lua_tonumber(state, -1);
                break;
            case LUA_TSTRING:
                value[key] = lua_tostring(state, -1).fromStringz;
                break;
            case LUA_TBOOLEAN:
                value[key] = lua_toboolean(state, -1);
                break;
            case LUA_TNIL:
                value[key] = null;
                break;
            case LUA_TTABLE:
                value[key] = JSONValue.init;
                _kmLuaDumpTablesRecurse(state, value[key]);
                break;
            default:
                value[key] = "%s=0x%X".format(cast(string)luaL_typename(state, -1).fromStringz, lua_topointer(state, -1));
                break;
        }
        lua_pop(state, 1);
    }
}
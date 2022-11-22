/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.scripting.utils;
import bindbc.lua;
import std.string;

/**
    Returns string from Lua stack
*/
string kmLuaGetString(lua_State* state, int offset) {
    const(char)* txt = lua_tostring(state, offset);
    size_t l = lua_strlen(state, offset);
    return cast(string)txt[0..l];
}

/**
    Returns whether a Lua stack element is a string
*/
bool kmLuaIsString(lua_State* state, int offset) {
    return cast(bool)lua_isstring(state, offset);
}
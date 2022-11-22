/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.scripting.reg;
import engine.scripting;
import bindbc.lua;
import std.traits;

struct KMLuaBind { string environment; }

enum isRegisterable(T) = (is(T == struct) || is(T == class)) && hasMember!(T, "id") && hasUDA!(T, KMLuaBind);

/**
    Adds the specified item in to the environment specified by the KMLuaBind UDA
*/
void kmLuaRegisterEntity(T)(lua_State* state, ref T item) if (isRegisterable!T) {
    KMLuaBind binding = getUDAs!(T, KMLuaBind)[0];

    static if(hasMember!(T, "script") && is(typeof(T.script) : string)) {

        // Load script if attached
        if (item.script.length > 0) {
            auto script = kmScriptStoreGet(item.script);
            script.load(state);
            kmLuaSetEntityEnv(state, binding.environment, item.id, &item);
            kmLuaLoadApply(state);
        }
    } else {
        kmLuaSetEntityEnv!false(state, binding.environment, item.id, &item);
    }
}

/**
    Removes the specified item from the environment specified by the KMLuaBind UDA
*/
void kmLuaDestroyEntity(T)(lua_State* state, ref T item) if (isRegisterable!T) {
    KMLuaBind binding = getUDAs!(T, KMLuaBind)[0];
    kmLuaDestroyEntityEnv(state, binding.environment, item.id);
}

/**
    Updates an existing entity in the environment specified by the KMLuaBind UDA
*/
void kmLuaUpdateEntity(T)(lua_State* state, ref T item) if (isRegisterable!T) {
    KMLuaBind binding = getUDAs!(T, KMLuaBind)[0];
    kmLuaSetEntityEnv(state, binding.environment, item.id, &item);
}
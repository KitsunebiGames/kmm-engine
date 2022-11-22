/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.scripting.engine;
import engine;
import bindbc.lua;
import std.string;

private {

    int _kmSetWindowTitle(lua_State* state) {
        GameWindow.title = kmLuaGetString(state, -1);
        return 0;
    }

    int _kmSetWorld(lua_State* state) {
        string worldName = kmLuaGetString(state, -1);
        
        return 0;
    }

    int _kmSetGameState(lua_State* state) {

        return 0;
    }
}

void kmLuaRegisterEngine() {
    
}
/*
    Game Content

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.gct;
public import engine.gct.actor;
public import engine.gct.room;
public import engine.gct.tile;
public import engine.gct.states;
import engine.scripting;

package(engine) {
    void initGCT() {
        kmWorldState = kmLuaNewState();
    }
}

/**
    State for the world
*/
static lua_State* kmWorldState;
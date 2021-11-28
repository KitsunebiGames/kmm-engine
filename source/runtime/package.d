module runtime;
import engine;
import engine.ver;
import std.format;

enum NOT_FOUND_MSG = "Game content not found!\nMake sure the runtime executable is in the game directory, or\nrun with the --editor flag to enter the game editor.";

/**
    Initialize game
*/
void _init() {
    GameWindow.setSwapInterval(SwapInterval.VSync);
    GameWindow.title = "Kitsunemimi Runtime (No Game Loaded)";


    auto state = kmLuaNewState();
    kmLuaLoad(state, "function test() end");
    kmLuaSetEntityEnv(state, "_ENTITIES", "TestEntity", null);
    kmLuaLoadApply(state);

    kmLuaLoad(state, "function test() end");
    kmLuaSetEntityEnv(state, "_ENTITIES", "TestEntity2", null);
    kmLuaLoadApply(state);

    kmLuaLoad(state, "function test() end function test2() end");
    kmLuaSetEntityEnv(state, "_ENTITIES", "TestEntity3", null);
    kmLuaLoadApply(state);
    
    AppLog.info("LUA", "%s", kmLuaDumpGlobalTable(state, "_ENTITIES"));

    kmLuaDestroyEntityEnv(state, "_ENTITIES", "TestEntity");
    kmLuaDestroyEntityEnv(state, "_ENTITIES", "TestEntity3");
    AppLog.info("LUA", "%s", kmLuaDumpGlobalTable(state, "_ENTITIES"));

    // No way to load game content yet
    throw new Exception(NOT_FOUND_MSG);
}

/**
    Update game
*/
void _update() {

}

/**
    Game cleanup
*/
void _cleanup() {

}

/**
    Render border
*/
void _border() {

}

/**
    Post-update
*/
void _postUpdate() {

}
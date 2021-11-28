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
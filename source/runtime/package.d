module runtime;
import engine;
import engine.ver;
import std.format;

enum NOT_FOUND_MSG = "Game content not found!\nMake sure the runtime executable is in the game directory, or\nrun with the --editor flag to enter the game editor.";
Music music;

/**
    Initialize game
*/
void _init(string[] args) {
    GameWindow.setSwapInterval(SwapInterval.VSync);
    GameWindow.title = "Kitsunemimi Runtime (No Game Loaded)";

    music = new Music(args[0]);
    music.setLooping(true);
    music.play();

    // No way to load game content yet
    AppLog.error("Runtime", "No game content found.");
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
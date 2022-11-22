module runtime;
import engine;
import engine.ver;
import std.format;
import inochi2d;
import bindbc.sdl : SDL_GetTicks;

enum NOT_FOUND_MSG = "Game content not found!\nMake sure the runtime executable is in the game directory, or\nrun with the --editor flag to enter the game editor.";
enum NOT_FOUND_MSG_FAIL = "Game content failed to load!\nMake sure the runtime executable is in the game directory, or\nrun with the --editor flag to enter the game editor.\n%s load failures registered.";
Music music;

/**
    Initialize game
*/
void _init(string[] args) {
    GameWindow.setSwapInterval(SwapInterval.VSync);
    GameWindow.title = "Kitsunemimi Runtime";

    // Check for package load errors
    if (kmPakGetCount() == 0) {
        GameWindow.title = "Kitsunemimi Runtime (No Game Loaded)";
        if (args.length > 0) {
            music = new Music(args[0]);
            music.setLooping(true);
            music.play();
        }

        // No game content found to load.
        AppLog.error("Runtime", "No game content found.");
        throw new Exception(kmPakGetFailed() == 0 ? NOT_FOUND_MSG : NOT_FOUND_MSG_FAIL.format(kmPakGetFailed()));
    }

    import std.file : readText;
    // KMScript script = KMScript(readText(args[1]));

    music = new Music(kmPakGetResource("music/tune0"));
    music.setLooping(true);
    music.play();

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
module game;
import engine;
import game.itr;
import game.entity;
import std.format;

/**
    Writes text to text log as "info"
*/
void logWrite(ref string text) {
    AppLog.info("Script Debug", text.dup);
}

/**
    Initialize game
*/
void _init() {
    GameWindow.setSwapInterval(SwapInterval.VSync);
    GameWindow.title = "Kitsunemimi";

    // Register debug stuff
    ScriptState.registerGlobalFunction("void logWrite(string text)", &logWrite);

    // And we also want to register our engine types
    registerTypes();

    //player = new Entity("Player", new Script(ScriptState, "player", readText("scripts/player.as")), vec2i(0, 0));
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

    debug {
        GameFont.setSize(16);
        GameFont.draw("%sms\n%s script(s) loaded"d.format(
            cast(int)(deltaTime()*1000),
            getScriptCount(),
        ), vec2(8, 8));
        GameFont.flush();
    }
}

/**
    The script state
*/
void registerTypes() {
    registerEntityType(ScriptState);
}
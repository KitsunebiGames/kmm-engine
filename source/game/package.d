module game;
import engine;
import std.format;
import std.compiler;

/**
    Initialize game
*/
void _init() {
    GameWindow.setSwapInterval(SwapInterval.VSync);
    GameWindow.title = "Kitsunemimi";
}

/**
    Update game
*/
void _update() {
    //GameFont.setSize(16);
    GameFont.setScale(2+sin(currTime()));
    GameFont.draw("=== Compile Info ===\ncompiler=%s\n%sms"d.format(
        name,
        cast(int)(deltaTime()*1000),
    ), vec2(8, 8));
    GameFont.flush();

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
    }
}
module runtime;
import engine;
import engine.ver;
import std.format;

enum NOT_FOUND_MSG1 = "Game content not found!";
enum NOT_FOUND_MSG2 = "Make sure the runtime executable is in the game directory, or";
enum NOT_FOUND_MSG3 = "run with the --editor flag to enter the game editor.";
vec2[] errMsgMeasure;
vec2 errMsgOrigin;

/**
    Initialize game
*/
void _init() {
    GameWindow.setSwapInterval(SwapInterval.VSync);
    GameWindow.title = "Kitsunemimi Runtime (No Game Loaded)";
    GameFont.setSize(20);
    errMsgMeasure ~= GameFont.measure(NOT_FOUND_MSG1);
    errMsgMeasure ~= GameFont.measure(NOT_FOUND_MSG2);
    errMsgMeasure ~= GameFont.measure(NOT_FOUND_MSG3);
}

/**
    Update game
*/
void _update() {
    errMsgOrigin = vec2(kmCameraViewWidth()/2, (kmCameraViewHeight()/2)-(GameFont.getMetrics().y*3/2));
    GameFont.setSize(20);
    GameFont.draw(NOT_FOUND_MSG1, errMsgOrigin+vec2(-errMsgMeasure[0].x/2, -10));
    GameFont.draw(NOT_FOUND_MSG2, errMsgOrigin+vec2(-errMsgMeasure[1].x/2, GameFont.getMetrics().y));
    GameFont.draw(NOT_FOUND_MSG3, errMsgOrigin+vec2(-errMsgMeasure[2].x/2, GameFont.getMetrics().y*2));
    GameFont.draw("v. %s"d.format(KM_VERSION), vec2(8, 8));
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

}
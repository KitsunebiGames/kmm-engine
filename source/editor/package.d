module editor;
import engine;

import editor.ui;

/**
    Initialize game
*/
void _init(string[] args) {
    GameWindow.setSwapInterval(SwapInterval.VSync);
    GameWindow.title = "Kitsunemimi Editor";

    kmEditorUIInit();
}

/**
    Update game
*/
void _update() {
    kmSetViewport(vec2i(GameWindow.width(), GameWindow.height()));
    GameFont.setScale(2);
    GameFont.draw!true("Hello, world!", vec2(16, 16));
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
    kmEditorDrawUI();
}
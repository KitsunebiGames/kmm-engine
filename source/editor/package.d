module editor;
import engine;

import editor.ui;

/**
    Initialize game
*/
void _init() {
    GameWindow.setSwapInterval(SwapInterval.VSync);
    GameWindow.title = "Kitsunemimi Editor";

    kmEditorUIInit();
}

/**
    Update game
*/
void _update() {
    GameFont.draw!true("Hello, world!", vec2(8, 8));
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
    kmEditorUIBegin();
    
        kmEditorUIMenuBar();

    kmEditorUIEnd();
}
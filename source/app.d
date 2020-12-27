module app;
import engine;

void _init() {

}

void _update() {

}

void _cleanup() {

}

void _border() {

}

void _postUpdate() {

}

int main() {

    // Set 
    gameInit = &_init;
    gameUpdate = &_update;
    gameCleanup = &_cleanup;

    // Init engine start the game and then close the engine once the game quits
    initEngine();
    startGame(vec2i(1920, 1080));
    closeEngine();
    return 0;
}
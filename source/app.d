module app;
import engine;
import game;

int main() {

    // Set the function pointers
    gameInit = &_init;
    gameUpdate = &_update;
    gameCleanup = &_cleanup;
    gameBorder = &_border;
    gamePostUpdate = &_postUpdate;

    // Init engine start the game and then close the engine once the game quits
    initEngine();
    startGame(vec2i(1920, 1080));
    closeEngine();
    return 0;
}
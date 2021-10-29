module app;
import engine;
import game;

int main() {

    // Set the function pointers
    kmInit = &_init;
    kmUpdate = &_update;
    kmCleanup = &_cleanup;
    kmBorder = &_border;
    kmPostUpdate = &_postUpdate;

    // Init engine start the game and then close the engine once the game quits
    initEngine();
    startGame(vec2i(1920/2, 1080/2));
    closeEngine();
    return 0;
}
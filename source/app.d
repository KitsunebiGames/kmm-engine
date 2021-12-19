module app;
import engine;
import rt = runtime;
import ed = editor;

int main(string[] args) {

    // Set the function pointers
    kmInit = &rt._init;
    kmUpdate = &rt._update;
    kmCleanup = &rt._cleanup;
    kmBorder = &rt._border;
    kmPostUpdate = &rt._postUpdate;

    if (args.length > 1) {
        if (args[1] == "--editor") {
            kmInit = &ed._init;
            kmUpdate = &ed._update;
            kmCleanup = &ed._cleanup;
            kmBorder = &ed._border;
            kmPostUpdate = &ed._postUpdate;
        }
    }

    // Init engine start the game and then close the engine once the game quits
    initEngine();
    startGame(args[1..$], vec2i(1920/2, 1080/2));
    closeEngine();
    return 0;
}
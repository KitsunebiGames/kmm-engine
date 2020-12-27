# VTuber Game Jam Engine
Fork of the [Kitsune Mahjong engine](https://github.com/KitsunebiGames/km-engine) for use in VTuber Game Jam

## Dependencies
The VTJam engine requires the following dependencies to be present to work:
 * OpenAL Driver ([OpenAL-Soft included on Windows](https://github.com/kcat/openal-soft))
 * OpenGL Driver
 * GLFW3
 * libogg
 * libvorbis
 * libvorbisfile
 * FreeType
 * Kosugi Maru Font (in [`res/fonts`](/res/fonts) w/ license)

On Windows these libraries are copied from the included libs/ folder.

## How to use
Add `vtjam-engine` as a dependency to your project (`dub add vtjam-engine`)

Bootstrap the engine with the following code:
```d
import engine;
void _init() {
    // Initialize your game's resources
    GameWindow.title = "My Game";
}

void _update() {
    // Update and draw your game
}

void _border() {
    // Draw a border if you want to
}

void _postUpdate() {
    // Draw a border if you want to
}

void _cleanup() {
    // Clean up resources when game is requested to close.
}

int main() {
    // Sets the essential game functions
    gameInit = &_init;
    gameUpdate = &_update;
    gameCleanup = &_cleanup;
    gameBorder = &_border;
    gamePostUpdate = &_postUpdate;

    // Handle game initialization, looping and closing the engine after use.
    // It's recommended using a try/catch block to catch any errors that might pop up.
    initEngine();
    startGame(vec2i(1920, 1080)); // The variable is the desired size of the game's frame buffer.
    closeEngine();
    return 0;
}
```
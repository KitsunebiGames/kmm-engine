/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine;
public import engine.core;
public import engine.input;
public import engine.render;
public import engine.math;
public import engine.audio;
public import engine.net;
public import engine.ui;
public import engine.game;
public import engine.i18n;

import bindbc.sdl;
import bindbc.openal;
import bindbc.freetype;

/**
    Initialize the game engine
*/
void initEngine() {
    // Initialize logger if needed
    if (AppLog is null) AppLog = new Logger();

    // Initialize SDL2
    initSDL();
    SDL_Init(SDL_INIT_EVERYTHING);
    AppLog.info("Engine", "SDL2 initialized...");

    // Initialize OpenAL
    initOAL();
    initAudioEngine();
    AppLog.info("Engine", "Audio Engine initialized...");

    // Create window
    GameWindow = new Window();
    GameWindow.makeCurrent();
    AppLog.info("Engine", "Window initialized...");

    // Initialize OpenGL and make context current
    initOGL();
    initRender();
    AppLog.info("Engine", "Renderer initialized...");

    // Initialize Font system
    initFT();
    initFontSystem();
    AppLog.info("Engine", "Font system initialized...");

    // Initialize input
    // initInput(GameWindow.winPtr);
    // AppLog.info("Engine", "Input system initialized...");

    // Initialize atlasser
    GameAtlas = new AtlasCollection();
    AppLog.info("Engine", "Texture atlassing initialized...");

    // Initialize subsystems
    AppLog.info("Engine", "Intialized internal state for renderer...");
}

/**
    Closes the engine and relases libraries, etc.
*/
void closeEngine() {

    // Stop music when game exits
    kmStopAllMusic();

    import core.memory : GC;
    destroy(GameWindow);
	destroy(AppLog);

    // Collect the stuff before we terminate all this other stuff
    // We let OpenGL, OpenAL and GLFW be terminated by the closing of the program
    GC.collect();
}

private void initOAL() {
    auto support = loadOpenAL();
    if (support == ALSupport.badLibrary) {
        AppLog.fatal("Engine", "Could not load OpenAL, bad library!");
    } else if (support == ALSupport.noLibrary) {
        AppLog.fatal("Engine", "Could not load OpenAL, no library found!");
    }
}

private void initSDL() {
    auto support = loadSDL();
    if (support == SDLSupport.badLibrary) {
        AppLog.fatal("Engine", "Could not load SDL2, bad library!");
    } else if (support == SDLSupport.noLibrary) {
        AppLog.fatal("Engine", "Could not load SDL2, no library found!");
    }
}

private void initOGL() {
    auto support = loadOpenGL();
    if (support == GLSupport.badLibrary) {
        AppLog.fatal("Engine", "Could not load OpenGL, bad library!");
    } else if (support == GLSupport.noLibrary) {
        AppLog.fatal("Engine", "Could not load OpenGL, no library found!");
    } else if (support == GLSupport.noContext) {
        AppLog.fatal("Engine", "OpenGL context was not created before loading OpenGL.");
    }
}

private void initFT() {
    auto support = loadFreeType();
    if (support == FTSupport.badLibrary) {
        AppLog.fatal("Engine", "Could not load FreeType, bad library!");
    } else if (support == FTSupport.noLibrary) {
        AppLog.fatal("Engine", "Could not load FreeType, no library found!");
    }
}
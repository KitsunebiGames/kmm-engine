/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.game;
import bindbc.sdl;
import engine;
import engine.config;

private double previousTime_ = 0;
private double currentTime_ = 0;
private double deltaTime_ = 0;
private double timeAccumulator = 0;

private Framebuffer framebuffer;

/**
    Function run when the game is to initialize
*/
void function() kmInit;

/**
    Function run when the game is to update
*/
void function() kmUpdate;

/**
    Fixed timestep updating
*/
void function() kmFixedUpdate;

/**
    Function run after the main rendering has happened, Used to draw borders for the gameplay
*/
void function() kmBorder;

/**
    Function run after updates and rendering of the game
*/
void function() kmPostUpdate;

/**
    Function run when the game is to clean up
*/
void function() kmCleanup;

/**
    Starts the game loop

    viewportSize sets the desired viewport size for the framebuffer, defaults to 1080p (1920x1080)
*/
void startGame(vec2i viewportSize = vec2i(1920, 1080)) {
    
    try {
        kmInit();
        currentTime_ = cast(double)SDL_GetPerformanceCounter()/cast(double)SDL_GetPerformanceFrequency();
        previousTime_ = currentTime_;

        framebuffer = new Framebuffer(GameWindow, viewportSize);
        while(!GameWindow.isExitRequested) {

            // Pump events for this update cycle
            SDL_PumpEvents();

            currentTime_ = cast(double)SDL_GetPerformanceCounter()/cast(double)SDL_GetPerformanceFrequency();
            deltaTime_ = currentTime_-previousTime_;
            previousTime_ = currentTime_;
            timeAccumulator += deltaTime_;
            
            // Bind our framebuffer
            framebuffer.bind();

                // Clear color and depth buffers
                glClearColor(0, 0, 0, 1);
                glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

                // Update and render the game
                kmUpdate();

                // Fixed timestep updates
                float tTimeAcc = 0;
                if (kmFixedUpdate) {
                    while(timeAccumulator >= KM_TIMESTEP && tTimeAcc < KM_MAX_TIMESTEP) {
                        timeAccumulator -= KM_TIMESTEP;
                        tTimeAcc += KM_TIMESTEP;
                        kmFixedUpdate();
                    }
                }

            // Unbind our framebuffer
            framebuffer.unbind();
        
            // Clear color and depth bits
            glClearColor(0, 0, 0, 0);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            // Draw border, framebuffer and post update content
            if (kmBorder !is null) kmBorder();
            framebuffer.renderToFit();
            if (kmPostUpdate !is null) kmPostUpdate();

            // Update the mouse's state
            Input.update();

            // Swap buffers and update the window
            GameWindow.swapBuffers();
            GameWindow.update();
            
            // Event handling
            SDL_Event ev;
            while(SDL_PollEvent(&ev) == 1) {
                Controller.update(&ev);
                TextInput.update(&ev);

                // Handle window close
                if (ev.window.event == SDL_WindowEventID.SDL_WINDOWEVENT_CLOSE) {
                    GameWindow.close();
                }
            }
        }
    } catch(Exception ex) {
        
        // Uncaught exceptions will cause the engine to show a fullscreen error.
        _kmRenderExceptionLoop(viewportSize, ex);
    }

    // Pop all states
    GameStateManager.popAll();

    // Game cleanup
    kmCleanup();
}

private void _kmRenderExceptionLoop(vec2i viewportSize, Exception ex) {
    import engine.core.err : kmSetException, kmRenderException;

    // Pop all states
    GameStateManager.popAll();

    // Game cleanup
    kmCleanup();

    // Sets the exception to be rendered.
    kmSetException(ex);

    currentTime_ = cast(double)SDL_GetPerformanceCounter()/cast(double)SDL_GetPerformanceFrequency();
    previousTime_ = currentTime_;

    framebuffer = new Framebuffer(GameWindow, viewportSize);
    while(!GameWindow.isExitRequested) {

        // Pump events for this update cycle
        SDL_PumpEvents();

        currentTime_ = cast(double)SDL_GetPerformanceCounter()/cast(double)SDL_GetPerformanceFrequency();
        deltaTime_ = currentTime_-previousTime_;
        previousTime_ = currentTime_;
        timeAccumulator += deltaTime_;

        // Bind our framebuffer
        framebuffer.bind();

            // Clear color and depth buffers
            glClearColor(0, 0, 0, 1);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            // Render the exception
            kmRenderException();
        
        // Unbind framebuffer
        framebuffer.unbind();

        // Render the error message
        framebuffer.renderToFit();

        // Swap buffers and update the window
        GameWindow.swapBuffers();
        GameWindow.update();
        
        // Event handling
        SDL_Event ev;
        while(SDL_PollEvent(&ev) == 1) {
            Controller.update(&ev);
            TextInput.update(&ev);

            // Handle window close
            if (ev.window.event == SDL_WindowEventID.SDL_WINDOWEVENT_CLOSE) {
                GameWindow.close();
            }
        }
    }
}

/**
    Resizes the game's viewport
*/
void kmSetViewport(vec2i size) {
    framebuffer.resize(size);
}

/**
    Gets the size of the framebuffer
*/
vec2i kmGetViewport() {
    return framebuffer.size;
}

/**
    Fixed timestep
*/
double fixedDelta() {
    return KM_TIMESTEP;
}

/**
    Gets delta time
*/
double deltaTime() {
    return deltaTime_;
}

/**
    Gets delta time
*/
double prevTime() {
    return previousTime_;
}

/**
    Gets delta time
*/
double currTime() {
    return currentTime_;
}

bool kmIsRunningSlowly() {
    return timeAccumulator > KM_MAX_TIMESTEP;
}
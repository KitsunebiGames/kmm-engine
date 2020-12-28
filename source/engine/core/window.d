/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.core.window;
import bindbc.sdl;
import bindbc.opengl;
import engine.render : kmViewport;

/**
    Static instance of the game window
*/
static Window GameWindow;

/**
    A Window
*/
class Window {
private:
    SDL_Window* window;
    SDL_GLContext ctx;
    string title_;
    int width_;
    int height_;

    int fbWidth;
    int fbHeight;

    bool fullscreen_;
    bool shouldClose;

public:

    /**
        Destructor
    */
    ~this() {
        SDL_DestroyWindow(window);
    }

    /**
        Constructor
    */
    this(string title = "My Game", int width = 640, int height = 480) {
        this.title_ = title;
        this.width_ = width;
        this.height_ = height;
        this.fbWidth = width;
        this.fbHeight = height;

        SDL_GL_SetAttribute( SDL_GLattr.SDL_GL_CONTEXT_MAJOR_VERSION, 3 );
        SDL_GL_SetAttribute( SDL_GLattr.SDL_GL_CONTEXT_MINOR_VERSION, 2 );
        SDL_GL_SetAttribute( SDL_GLattr.SDL_GL_CONTEXT_PROFILE_MASK, SDL_GLprofile.SDL_GL_CONTEXT_PROFILE_COMPATIBILITY );
        window = SDL_CreateWindow(
            this.title_.ptr, 
            SDL_WINDOWPOS_UNDEFINED, 
            SDL_WINDOWPOS_UNDEFINED, 
            width, 
            height, 
            SDL_WindowFlags.SDL_WINDOW_OPENGL | SDL_WindowFlags.SDL_WINDOW_RESIZABLE
        );
        ctx = SDL_GL_CreateContext(window);
        
    }

    /**
        Hides the window
    */
    void hide() {
        SDL_HideWindow(window);
    }

    /**
        Show window
    */
    void show() {
        SDL_ShowWindow(window);
    }

    /**
        Gets the title of the window
    */
    @property string title() {
        return this.title_;
    }

    /**
        Sets the title of the window
    */
    @property void title(string value) {
        this.title_ = value;
        SDL_SetWindowTitle(window, this.title_.ptr);
    }

    /**
        Gets the width of the window's framebuffer
    */
    @property int width() {
        return this.fbWidth;
    }

    /**
        Gets the height of the window's framebuffer
    */
    @property int height() {
        return this.fbHeight;
    }

    /**
        Resizes the window
    */
    void resize(int width, int height) {
        this.width_ = width;
        this.height_ = height;
        SDL_SetWindowSize(window, width, height);
    }

    /**
        Gets whether the window is fullscreen
    */
    bool fullscreen() {
        return fullscreen_;
    }

    /**
        Sets the window's fullscreen state
    */
    void fullscreen(bool value) {
        if (this.fullscreen_ == value) return;

        SDL_SetWindowFullscreen(window, value ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
        this.fullscreen_ = value;
    }

    /**
        poll for new window events
    */
    void update() {
        SDL_GL_GetDrawableSize(window, &fbWidth, &fbHeight);
    }

    /**
        Set the close request flag
    */
    void close() {
        shouldClose = true;
    }

    /**
        Gets whether the window has requested to close (aka the game is requested to exit)
    */
    bool isExitRequested() {
        return shouldClose;
    }

    /**
        Makes the OpenGL context of the window current
    */
    void makeCurrent() {
        SDL_GL_MakeCurrent(window, ctx);
    }

    /**
        Swaps the OpenGL buffers for the window
    */
    void swapBuffers() {
        SDL_GL_SwapWindow(window);
    }

    /**
        Sets the swap interval, by default vsync
    */
    void setSwapInterval(SwapInterval interval = SwapInterval.VSync) {
        SDL_GL_SetSwapInterval(cast(int)interval);
    }

    /**
        Resets the OpenGL viewport to fit the window
    */
    void resetViewport() {
        kmViewport(0, 0, width, height);
    }

    /**
        Gets the glfw window pointer
    */
    SDL_Window* winPtr() {
        return window;
    }
}

/**
    A swap interval
*/
enum SwapInterval : int {
    Unlimited = 0,
    VSync = 1,
    Adaptive = -1
}
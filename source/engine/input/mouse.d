/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.input.mouse;
import engine.input;
import bindbc.sdl;
import gl3n.linalg;

/**
    The buttons on a mouse
*/
enum MouseButton {
    Left = SDL_BUTTON_LMASK ,
    Middle = SDL_BUTTON_MMASK,
    Right = SDL_BUTTON_RMASK,
    X1 = SDL_BUTTON_X1MASK,
    X2 = SDL_BUTTON_X2MASK
}

/**
    The state of the mouse
*/
struct MouseState {
private:
    int btnMask;

public:

    /**
        Position of the mouse, z is scroll
    */
    vec3 position;

    /**
        Initialize this mouse state
    */
    this(vec3 pos, int btnMask) {
        this.position = pos;
        this.btnMask = btnMask;
    }

    /**
        Gets whether a mouse button is pressed
    */
    bool isButtonPressed(MouseButton button) {
        return (btnMask & button) > 0;
    }

    /**
        Gets whether a mouse button is released
    */
    bool isButtonReleased(MouseButton button) {
        return (btnMask & button) > 0;
    }
}

/**
    Mouse
*/
class Mouse {
private static:
    vec2i lastPos;

public static:

    MouseState* getState() {

        // Get mouse state
        int* x, y;
        immutable(int) mask = SDL_GetMouseState(x, y);
        
        // Fallback to last position if needed
        if (x is null) x = &lastPos.vector[0];
        if (y is null) y = &lastPos.vector[1];

        // Set position
        lastPos = vec2i(*x, *y);

        // TODO: Get scroll from events
        float scroll = 0;
        return new MouseState(vec3(*x, *y, scroll), mask);
    }

    /**
        Position of the cursor
    */
    static vec2 position() {

        // Get mouse state
        int* x, y;
        SDL_GetMouseState(x, y);
        
        // Fallback to last position if needed
        if (x is null) x = &lastPos.vector[0];
        if (y is null) y = &lastPos.vector[1];

        lastPos = vec2i(*x, *y);
        return vec2(*x, *y);
    }
}
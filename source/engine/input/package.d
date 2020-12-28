/*
    Input Handling Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.input;
import bindbc.sdl;

public import engine.input.keyboard;
public import engine.input.mouse;
public import engine.input.controller;
public import engine.input.text;

private {
    enum BindingType {
        Key,
        Button,
        Axis
    }

    struct KeyBinding {
        Key key;
        bool lastState;
        bool currentState;
    }

    struct ButtonBinding {
        Button button;
        bool lastState;
        bool currentState;
    }

    struct AxisBinding {
        Axis axis;
        float pval;
        float val;
    }
    
    struct Binding {
        BindingType type;
        union {
            KeyBinding kb;
            ButtonBinding bb;
            AxisBinding ab;
        }
    }
}

class Input {
private static:
    Binding[string] bindings;
    KeyboardState* state;

public static:
    /**
        Updates the keybinding states
    */
    void update() {
        state = Keyboard.getState();

        // // Update keybindings
        // foreach(binding; bindings) {
        //     binding.lstate = binding.state;
        //     binding.state = state.isKeyDown(binding.key);
        // }
    }
}
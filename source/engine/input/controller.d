module engine.input.controller;
import bindbc.sdl;
import std.exception;

/**
    Controller types
*/
enum ControllerType {
    Unknown = 0,
    XBox360 = SDL_GameControllerType.SDL_CONTROLLER_TYPE_XBOX360,
    XBoxOne = SDL_GameControllerType.SDL_CONTROLLER_TYPE_XBOXONE,
    DualShock3 = SDL_GameControllerType.SDL_CONTROLLER_TYPE_PS3,
    DualShock4 = SDL_GameControllerType.SDL_CONTROLLER_TYPE_PS4,
    SwitchPro = SDL_GameControllerType.SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_PRO
}

/**
    An axis
*/
enum Axis {
    LeftThumbstick = SDL_GameControllerAxis.SDL_CONTROLLER_AXIS_LEFTX,
    RightThumbstick = SDL_GameControllerAxis.SDL_CONTROLLER_AXIS_RIGHTX,
    TriggerLeft = SDL_GameControllerAxis.SDL_CONTROLLER_AXIS_TRIGGERLEFT,
    TriggerRight = SDL_GameControllerAxis.SDL_CONTROLLER_AXIS_TRIGGERRIGHT
}

/**
    Controller buttons
*/
enum Button {
    A = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_A,
    B = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_B,
    X = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_X,
    Y = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_Y,
    Back = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_BACK,
    Guide = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_GUIDE,
    Start = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_START,
    LeftStick = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_LEFTSTICK,
    RightStick = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_RIGHTSTICK,
    LeftShoulder = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_LEFTSHOULDER,
    RightShoulder = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_RIGHTSHOULDER,
    DPUp = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_DPAD_UP,
    DPDown = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_DPAD_DOWN,
    DPLeft = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_DPAD_LEFT,
    DPRight = SDL_GameControllerButton.SDL_CONTROLLER_BUTTON_DPAD_RIGHT,
}

/**
    A controller
*/
class Controller {
private:
    SDL_GameController* controller;

    void update() {
        SDL_GameControllerUpdate();
    }

public:
    /**
        Close the controller when this instance doesn't exist anymore
    */
    ~this() {
        SDL_GameControllerClose(controller);
    }

    /**
        Open controller with id
    */
    this(int id) {
        enforce(SDL_IsGameController(id), "Input device was not a controller");
        controller = SDL_GameControllerOpen(id);
    }

    /**
        Gets whether the controller is connected and available for use
    */
    bool isAttached() {
        return SDL_GameControllerGetAttached(controller);
    }

    /**
        Gets the type of the controller
    */
    ControllerType type() {
        return cast(ControllerType)SDL_GameControllerGetType(controller);
    }

    /**
        Gets whether the controller button is pressed
    */
    bool isButtonPressed(Button button) {
        return SDL_GameControllerGetButton(controller, button);
    }

    /**
        Gets whether the button is released
    */
    bool isButtonReleased(Button button) {
        return SDL_GameControllerGetButton(controller, button);
    }

    /**
        Gets left thumbstick
    */
    vec2 getLeftThumbstick() {
        short x = SDL_GameControllerGetAxis(controller, cast(int)Axis.LeftThumbstick);
        short y = SDL_GameControllerGetAxis(controller, cast(int)Axis.LeftThumbstick+1);
        return vec2(cast(float)x/cast(float)short.max, cast(float)y/cast(float)short.max);
    }

    /**
        Gets right thumbstick
    */
    vec2 getRightThumbstick() {
        short x = SDL_GameControllerGetAxis(controller, cast(int)Axis.RightThumbstick);
        short y = SDL_GameControllerGetAxis(controller, cast(int)Axis.RightThumbstick+1);
        return vec2(cast(float)x/cast(float)short.max, cast(float)y/cast(float)short.max);
    }

    /**
        How pressed down the left trigger is
    */
    float leftTrigger() {
        short val =  SDL_GameControllerGetAxis(controller, Axis.TriggerLeft);
        return cast(float)val/short.max;
    }

    /**
        How pressed down the left trigger is
    */
    float rightTrigger() {
        short val =  SDL_GameControllerGetAxis(controller, Axis.TriggerRight);
        return cast(float)val/short.max;
    }

    /**
        Makes the controller rumble for specified duration (in ms)
        
        Returns false if the controller doesn't support rumble
    */
    bool rumble(ushort left, ushort right, uint duration) {
        return SDL_GameControllerRumble(controller, left, right, duration) == 0;
    }

    /**
        Makes the controller rumble for specified duration (in ms)
        
        Returns false if the controller doesn't support rumble
    */
    bool rumble(ushort both, uint duration) {
        return rumble(both, both, duration);
    }
}
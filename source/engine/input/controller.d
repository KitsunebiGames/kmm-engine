module engine.input.controller;
import bindbc.sdl;
import std.exception;
import containers.list;

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
enum Axis : SDL_GameControllerAxis {
    LeftStickX = SDL_GameControllerAxis.SDL_CONTROLLER_AXIS_LEFTX,
    LeftStickY = SDL_GameControllerAxis.SDL_CONTROLLER_AXIS_LEFTY,
    RightStickX = SDL_GameControllerAxis.SDL_CONTROLLER_AXIS_RIGHTX,
    RightStickY = SDL_GameControllerAxis.SDL_CONTROLLER_AXIS_RIGHTY,
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
    Players
*/
enum PlayerIndex {
    PlayerOne,
    PlayerTwo,
    PlayerThree,
    PlayerFour
}

/**
    Contoller manager
*/
class Controller {
private:
    static List!ControllerInstance controllers;

package(engine):
    static void update(SDL_Event* ev) {
        switch(ev.type) {
            case SDL_EventType.SDL_JOYDEVICEADDED:

                // Doesn't matter if it's not a controller
                if (!SDL_IsGameController(ev.jdevice.which)) break;

                // Add controller to map
                controllers.add(new ControllerInstance(ev.jdevice.which));
                break;

            case SDL_EventType.SDL_JOYDEVICEREMOVED:

                // Doesn't matter if it's not a controller
                if (!SDL_IsGameController(ev.jdevice.which)) break;

                // Find the controller we want to remove
                int controllerToRemove = -1;
                foreach(i; 0..controllers.count) {
                    if (controllers[i].id == ev.jdevice.which) {
                        controllerToRemove = cast(int)i;
                        break; 
                    }
                }

                // Couldn't find controller???
                if (controllerToRemove == -1) break;

                // Remove the controller that we can't use anymore
                controllers.removeAt(controllerToRemove);
                break;

            // We only handle controller events here
            default: break;
        }
    }

public:
    /**
        Gets the amount of controllers
    */
    static size_t count() {
        return controllers.count;
    }

    /**
        Gets whether a controller is present
    */
    static bool has(int index) {
        return index >= 0 && index < controllers.count;
    }

    /**
        Gets the state of the player's controller
    */
    static ControllerInstance getController(int index) {
        return controllers[index];
    }
}

/**
    A controller
*/
class ControllerInstance {
private:
    SDL_GameController* controller;
    int id;

    void update() {
        SDL_GameControllerUpdate();
    }

    /**
        Open controller with id
    */
    this(int id) {
        this.id = id;
        enforce(SDL_IsGameController(id), "Input device was not a controller");
        controller = SDL_GameControllerOpen(id);
    }

public:
    /**
        Close the controller when this instance doesn't exist anymore
    */
    ~this() {
        SDL_GameControllerClose(controller);
    }

    /**
        Gets whether the controller is connected and available for use
    */
    bool isAttached() {
        return cast(bool)SDL_GameControllerGetAttached(controller);
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
        return cast(bool)SDL_GameControllerGetButton(controller, button);
    }

    /**
        Gets whether the button is released
    */
    bool isButtonReleased(Button button) {
        return cast(bool)SDL_GameControllerGetButton(controller, button);
    }

    /**
        X position of left stick
    */
    float leftStickX() {
        return cast(float)SDL_GameControllerGetAxis(controller, Axis.LeftStickX)/cast(float)short.max;
    }

    /**
        Y position of left stick
    */
    float leftStickY() {
        return cast(float)SDL_GameControllerGetAxis(controller, Axis.LeftStickY)/cast(float)short.max;
    }

    /**
        X position of right stick
    */
    float rightStickX() {
        return cast(float)SDL_GameControllerGetAxis(controller, Axis.RightStickX)/cast(float)short.max;
    }

    /**
        Y position of right stick
    */
    float rightSitckY() {
        return cast(float)SDL_GameControllerGetAxis(controller, Axis.RightStickY)/cast(float)short.max;
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
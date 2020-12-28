module engine.input.text;
import engine;
import bindbc.sdl;
import std.string;
import std.utf : strideBack;

/**
    Text input system
*/
class TextInput {
private static:
    bool isReadingText;

package(engine) static:
    void update(SDL_Event* event) {

        // Skip when we're not reading text
        if (!isReadingText) return;

        // Text handler
        switch(event.type) {
            // Handle clipboard and delete
            case SDL_EventType.SDL_KEYDOWN:
                if (event.key.keysym.sym == SDL_Keycode.SDLK_RETURN && returnEndsInput && composition.length == 0) {
                    
                    // We'll end the text input here
                    endTextInput();
                    break;

                } if (event.key.keysym.sym == SDL_Keycode.SDLK_BACKSPACE && text.length > 0) {

                    // Remove a character
                    text.length -= strideBack(text);

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_c && (event.key.keysym.mod == SDL_Keymod.KMOD_LCTRL || event.key.keysym.mod == SDL_Keymod.KMOD_RCTRL)) {
                    
                    // Copy text
                    SDL_SetClipboardText(text.ptr);

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_v && (event.key.keysym.mod == SDL_Keymod.KMOD_LCTRL || event.key.keysym.mod == SDL_Keymod.KMOD_RCTRL)) {
                    
                    // Skip if there's no text to paste
                    if (!SDL_HasClipboardText()) break;

                    // Paste text
                    text ~= cast(string)SDL_GetClipboardText().fromStringz;

                }
                break;
            
            // Handle IME
            case SDL_EventType.SDL_TEXTEDITING:
                composition = cast(string)event.edit.text.ptr.fromStringz;
                ccursor = event.edit.start;
                cselection = event.edit.length;
                break;

            // Handle input
            case SDL_EventType.SDL_TEXTINPUT:
                text ~= composition.ptr.fromStringz;
                break;

            // We only wanna handle textevents
            default: break;
        }        
    }

    void beginText() {
        if (isReadingText) SDL_StartTextInput();
    }

    void endText() {
        if (isReadingText) SDL_StopTextInput();
    }

public static:

    /**
        Where the cursor is in the composition
    */
    uint ccursor;

    /**
        How many characters are in composition
    */
    uint cselection;

    /**
        The current composition string
    */
    string composition;

    /**
        The current text
    */
    string text;

    /**
        Whether pressing RETURN will end the input mode
    */
    bool returnEndsInput = true;

    /**
        Sets the input area for IME display
    */
    void setInputArea(Rect rect) {
        SDL_Rect r = reinterpret_cast!SDL_Rect(rect);
        SDL_SetTextInputRect(&r);
    }

    /**
        Whether the user is in text input mode
    */
    bool isInputting() {
        return isReadingText;
    }

    /**
        Gets whether the user is currently composing text via IME
    */
    bool isComposing() {
        return composition.length > 0;
    }

    /**
        This resets the text buffer

        Starts text input mode
    */
    void startTextInput() {
        text = "";
        isReadingText = true;
    }

    /**
        Stops text input mode and returns the text which was input
    */
    string endTextInput() {
        string outText = text.idup;
        isReadingText = false;

        // Reset candidate and text
        cselection = 0;
        ccursor = 0;
        composition = "";

        return outText;
    }

    /**
        Make a copy of the text in the text buffer
    */
    string copyText() {
        return text.idup;
    }
}
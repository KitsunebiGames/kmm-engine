module engine.input.text;
import engine;
import bindbc.sdl;
import std.string;
import std.utf : strideBack, stride;

/**
    Text input system
*/
class TextInput {
private static:
    bool isReadingText;

package(engine) static:
    void update(SDL_Event* event) {

        import std.stdio : writeln;

        // Skip when we're not reading text
        if (!isReadingText) return;

        // Text handler
        switch(event.type) {
            // Handle clipboard and delete
            case SDL_EventType.SDL_KEYDOWN:
                if (event.key.keysym.sym == SDL_Keycode.SDLK_RETURN && returnEndsInput && !isComposing) {
                    
                    // We'll end the text input here
                    endTextInput();
                    break;

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_BACKSPACE && text.length > 0 && !isComposing) {

                    if (selection == 0) {

                        // We don't want to delete past the beginning
                        if (cursor == 0) break;

                        // Get amount of bytes in the UTF8 character
                        uint charWidth = strideBack(text, cursor);

                        // Remove it then update the cursor
                        text = text[0..cursor-charWidth] ~ text[cursor..$]; // Remove a character
                        cursor = cursor-charWidth;

                    } else {

                        // In case of selection remove multiple
                        // In this case the cursor should stay in the same place but the selection be reset
                        text = text[0..cursor] ~ text[cursor+selection..$];
                        selection = 0;
                    }

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_DELETE && text.length > 0 && !isComposing) {

                    if (selection == 0) {

                        // We don't want to delete past the end
                        if (cursor == text.length) break;

                        // Get amount of bytes in the UTF8 character
                        uint charWidth = stride(text, cursor);

                        // Remove it then update the cursor
                        text = text[0..cursor] ~ text[cursor+charWidth..$]; // Remove a character

                    } else {

                        // In case of selection remove multiple
                        // In this case the cursor should stay in the same place but the selection be reset
                        text = text[0..cursor] ~ text[cursor+selection..$];
                        selection = 0;
                    }

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_LEFT && text.length > 0 && (event.key.keysym.mod == SDL_Keymod.KMOD_LSHIFT || event.key.keysym.mod == SDL_Keymod.KMOD_RSHIFT) && !isComposing) {

                    // TODO: allow backwards selection by shifting cursor?

                    // Skip if our selection is already 0
                    if (selection == 0) break;

                    // Move the selection by 1 UTF8 codepoint
                    selection -= strideBack(text, cursor+selection);

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_RIGHT && text.length > 0 && (event.key.keysym.mod == SDL_Keymod.KMOD_LSHIFT || event.key.keysym.mod == SDL_Keymod.KMOD_RSHIFT) && !isComposing) {

                    // Skip if we're already at end of string
                    if (cursor+selection == text.length) break;

                    // Move the selection by 1 UTF8 codepoint
                    selection += stride(text, cursor+selection);

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_LEFT && text.length > 0 && !isComposing) {

                    // Skip if we're already at beginning of string
                    if (cursor == 0) break;

                    // Move the cursor by 1 UTF8 codepoint
                    cursor -= strideBack(text, cursor);

                    // Moving cursor will reset selection
                    selection = 0;

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_RIGHT && text.length > 0 && !isComposing) {

                    // Skip if we're already at end of string
                    if (cursor == text.length) break;

                    // Move the cursor by 1 UTF8 codepoint
                    cursor += stride(text, cursor);

                    // Moving cursor will reset selection
                    selection = 0;

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_c && (event.key.keysym.mod == SDL_Keymod.KMOD_LCTRL || event.key.keysym.mod == SDL_Keymod.KMOD_RCTRL) && !isComposing) {
                    
                    // Copy text
                    SDL_SetClipboardText(text.ptr);

                } else if (event.key.keysym.sym == SDL_Keycode.SDLK_v && (event.key.keysym.mod == SDL_Keymod.KMOD_LCTRL || event.key.keysym.mod == SDL_Keymod.KMOD_RCTRL) && !isComposing) {
                    
                    // Skip if there's no text to paste, otherwise fetch text from clipboard
                    if (!SDL_HasClipboardText()) break;
                    string cText = cast(string)SDL_GetClipboardText().fromStringz;

                    // Paste text, replacing any selected text in the process
                    text = text[0..cursor] ~ cText ~ text[cursor+selection..$];

                    // Move cursor by the amount of unicode points in text
                    cursor += cText.length;
                }
                break;
            
            // Handle IME
            case SDL_EventType.SDL_TEXTEDITING:
                composition = cast(string)(event.edit.text.dup.ptr).fromStringz;
                ccursor = event.edit.start;
                cselection = event.edit.length;
                break;

            // Handle input
            case SDL_EventType.SDL_TEXTINPUT:
                string cText = cast(string)(event.text.text.dup.ptr).fromStringz;

                // Replace selection if need be
                text = text[0..cursor] ~ cText ~ text[cursor+selection..$];
                cursor += cText.length;

                // Reset selection after this.
                selection = 0;
                break;

            // We only wanna handle textevents
            default: break;
        }        
    }

public static:

    /**
        Where the cursor is in the text
    */
    uint cursor;

    /**
        The characters selected from beginning of cursor
    */
    uint selection;

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
        Gets text with composition string spliced in
    */
    string textWithComposition() {
        return text[0..cursor] ~ composition ~ text[cursor+cselection..$];
    }

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
    void startTextInput(string startText = "") {
        text = startText;
        isReadingText = true;
        SDL_StartTextInput();
    }

    /**
        Stops text input mode and returns the text which was input
    */
    string endTextInput() {
        string outText = text.idup;
        isReadingText = false;
        SDL_StopTextInput();

        // Reset candidate and text
        cselection = 0;
        ccursor = 0;
        cursor = 0;
        selection = 0;
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
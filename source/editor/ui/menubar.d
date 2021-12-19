module editor.ui.menubar;
import engine;
import engine.ver;
import bindbc.imgui;
import std.format;

void kmEditorUIMenuBar() {
    if (igBeginMainMenuBar()) {
        if (igBeginMenu("File", true)) {

            // if (igMenuItem("New")) {

            // }

            // if (igMenuItem("Open")) {

            // }

            // if (igBeginMenu("Recent...", true)) {

            //     igEndMenu();
            // }

            if (igMenuItem("Save")) {
            }

            if (igMenuItem("Exit")) {
                GameWindow.close();
            }

            igEndMenu();
        }

        if (igBeginMenu("Edit", true)) {
            
            igEndMenu();
        }

        if (igBeginMenu("Game", true)) {

            if (igMenuItem("Build", "Shift+F5")) {
                
            }

            if (igMenuItem("Build and Run", "F5")) {
                
            }
            
            igEndMenu();
        }

        if (igBeginMenu("Help", true)) {

            if (igMenuItem("Documentation")) {
                
            }

            if (igMenuItem("About")) {

            }

            igSeparator();
            igText("v. %s", KM_VERSION.ptr);
            
            igEndMenu();
        }

        // End the menu bar
        igEndMainMenuBar();
    }
}
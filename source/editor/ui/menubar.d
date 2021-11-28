module editor.ui.menubar;
import engine.ver;
import bindbc.imgui;
import std.format;

void kmEditorUIMenuBar() {
    if (igBeginMainMenuBar()) {
        if (igBeginMenu("File", true)) {

            if (igMenuItem("New Project")) {
            }

            igEndMenu();
        }

        if (igBeginMenu("Edit", true)) {
            
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
module editor.ui.menubar;
import bindbc.imgui;

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
            
            igEndMenu();
        }

        // End the menu bar
        igEndMainMenuBar();
    }
}
module editor.ui.elementlist;
import bindbc.imgui;

void kmEditorElementListWindow() {
    auto flags = 
        ImGuiWindowFlags.NoTitleBar | 
        ImGuiWindowFlags.NoResize;
    if (igBegin("#ElementList", null, flags)) {

        igEnd();
    }
}
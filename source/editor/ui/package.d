module editor.ui;
public import editor.ui.core : kmEditorUIBegin, kmEditorUIEnd, kmEditorUIInit;
public import editor.ui.menubar;
public import editor.ui.elementlist;
import bindbc.imgui;

private ImGuiID dockspace;
void kmEditorSetupUI() {
    // Root docking node
    dockspace = igDockSpaceOverViewport(null, cast(ImGuiDockNodeFlags)0, null);

    igDockBuilderRemoveNode(dockspace);
    igDockBuilderAddNode(dockspace, ImGuiDockNodeFlags.PassthruCentralNode);
    auto left = igDockBuilderSplitNode(dockspace, ImGuiDir.Left, 0.20f, null, &dockspace);
    auto right = igDockBuilderSplitNode(dockspace, ImGuiDir.Right, 0.20f, null, &dockspace);
    auto down = igDockBuilderSplitNode(dockspace, ImGuiDir.Down, 0.20f, null, &dockspace);

    igDockBuilderDockWindow("ElementList", left);
    igDockBuilderDockWindow("Options", right);
    igDockBuilderDockWindow("Resources", down);

    igDockBuilderFinish(dockspace);
}

void kmEditorDrawUI() {
    kmEditorUIBegin();
        if (!igDockBuilderGetNode(dockspace)) {
            kmEditorSetupUI();   
        }
    
        kmEditorUIMenuBar();
        kmEditorElementListWindow();

    kmEditorUIEnd();
}
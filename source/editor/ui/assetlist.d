module editor.ui.assetlist;
import bindbc.imgui;

void kmEditorAssetListWindow() {
    auto flags = 
        ImGuiWindowFlags.NoTitleBar;
    if (igBegin("#AssetList", null, flags)) {

        igEnd();
    }
}
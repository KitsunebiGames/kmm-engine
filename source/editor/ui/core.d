module editor.ui.core;
import bindbc.imgui;
import bindbc.imgui.ogl;
import bindbc.sdl;
import std.exception;
import engine;

private {

    void _kmAddFontData(string name, ref ubyte[] data, float size = 14, const ImWchar* ranges = null, ImVec2 offset = ImVec2(0f, 0f)) {
        auto atlas = igGetIO().Fonts;
        
        auto cfg = ImFontConfig_ImFontConfig();
        cfg.FontDataOwnedByAtlas = false;
        cfg.MergeMode = atlas.Fonts.empty() ? false : true;
        cfg.GlyphOffset = offset;

        char[40] nameDat;
        nameDat[0..name.length] = name[0..name.length];
        cfg.Name = nameDat;
        ImFontAtlas_AddFontFromMemoryTTF(atlas, cast(void*)data.ptr, cast(int)data.length, size, cfg, ranges);
    }
}

void kmEditorUIInit() {
    auto imSupport = loadImGui();
    enforce(imSupport != ImGuiSupport.noLibrary, "cimgui library not found!");
    //enforce(imSupport != ImGuiSupport.badLibrary, "Bad cimgui library found!");

    igCreateContext(null);
    auto io = igGetIO();

    // Build font atlas with basic font
    auto atlas = io.Fonts;
    _kmAddFontData("APP\0", PIXEL_M_PLUS_10, 14, ImFontAtlas_GetGlyphRangesJapanese(atlas));
    ImFontAtlas_Build(atlas);

    // Setup configuration
    io.ConfigFlags |= ImGuiConfigFlags.DockingEnable;           // Enable Docking
    io.ConfigFlags |= ImGuiConfigFlags.ViewportsEnable;         // Enable Viewports (causes freezes)
    io.ConfigWindowsResizeFromEdges = true;                     // Enable Edge resizing

    // Init stuff
    ImGui_ImplSDL2_InitForOpenGL(GameWindow.winPtr(), GameWindow.glPtr());
    ImGuiOpenGLBackend.init(null);
}

void kmEditorUIBegin() {
    // Start the Dear ImGui frame
    ImGuiOpenGLBackend.new_frame();
    ImGui_ImplSDL2_NewFrame();
    igNewFrame();

    // Add docking space
    //ImGuiID viewportDock = igDockSpaceOverViewport(null, cast(ImGuiDockNodeFlags)0, null);
}

void kmEditorUIEnd() {

    auto io = igGetIO();

    // Rendering
    igRender();
    glViewport(0, 0, cast(int)io.DisplaySize.x, cast(int)io.DisplaySize.y);
    ImGuiOpenGLBackend.render_draw_data(igGetDrawData());

    if (io.ConfigFlags & ImGuiConfigFlags.ViewportsEnable) {
        SDL_Window* currentWindow = SDL_GL_GetCurrentWindow();
        SDL_GLContext currentCtx = SDL_GL_GetCurrentContext();
        igUpdatePlatformWindows();
        igRenderPlatformWindowsDefault();
        SDL_GL_MakeCurrent(currentWindow, currentCtx);
    }
}
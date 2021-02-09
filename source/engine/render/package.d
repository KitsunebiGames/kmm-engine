/*
    Rendering Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.render;
import std.string;
public import bindbc.opengl;
public import engine.render.shader;
public import engine.render.texture;
public import engine.render.batcher;
public import engine.render.fbo;
public import engine.render.particlesystem;

void initRender() {

    glVersion = cast(string)glGetString(GL_VERSION).fromStringz;
    glVendor = cast(string)glGetString(GL_VENDOR).fromStringz;
    glGPU = cast(string)glGetString(GL_RENDERER).fromStringz;
    glGLSLVersion = cast(string)glGetString(GL_SHADING_LANGUAGE_VERSION).fromStringz;
    
    // OpenGL prep stuff
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    GameBatch = new SpriteBatch();
    initParticleSystem();
}

private int viewportX;
private int viewportY;
private int viewportW;
private int viewportH;

private string glVersion;
private string glVendor;
private string glGPU;
private string glGLSLVersion;

/**
    Sets the viewport
*/
void kmViewport(int x, int y, int width, int height) {
    import engine.math.camera : kmSetCameraTargetSize;

    viewportX = x;
    viewportY = y;
    viewportW = width;
    viewportH = height;
    glViewport(x, y, width, height);
    kmSetCameraTargetSize(width, height);
}

/**
    Returns the viewport X
*/
int kmViewportX() {
    return viewportX;
}

/**
    Returns the viewport Y
*/
int kmViewportY() {
    return viewportY;
}

/**
    Returns the viewport width
*/
int kmViewportWidth() {
    return viewportW;
}

/**
    Returns the viewport height
*/
int kmViewportHeight() {
    return viewportH;
}

/**
    Returns the OpenGL version
*/
string kmGLVersion() {
    return glVersion;
}

/**
    Gets the vendor of the GPU
*/
string kmGLVendor() {
    return glVendor;
}

/**
    Gets the name of the GPU which is rendering the game
*/
string kmGLGPU() {
    return glGPU;
}

/**
    Gets the primary GLSL version the GPU supports
*/
string kmGLSLVersion() {
    return glGLSLVersion;
}
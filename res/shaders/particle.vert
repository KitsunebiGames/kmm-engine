/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
#version 420

uniform mat4 vp;
uniform float size;
layout(location = 0) in vec2 verts;
layout(location = 1) in vec4 color;
layout(location = 2) in float scale;

out vec4 exColor;

void main() {
    exColor = color;

    gl_Position = vp * vec4(verts.x, verts.y, 0, 1);
    gl_PointSize = size*scale;
}
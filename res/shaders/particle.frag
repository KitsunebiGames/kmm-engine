/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
#version 430
uniform sampler2D tex;

in vec4 exColor;
out vec4 outColor;

void main() {
    outColor = (texture(tex, gl_PointCoord.st) * exColor); // 
}
/*
    Various core functionality

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.core;
public import engine.core.log;
public import engine.core.window;
public import engine.core.astack;
public import engine.core.strings;
public import engine.core.state;

/**
    Forcibly "casts" one type to an other
*/
@trusted
T reinterpret_cast(T, X)(X toCast) {
    union caster { T o; X i; }
    caster c;
    c.i = toCast;
    return c.o;
}
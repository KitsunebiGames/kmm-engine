module engine.scripting;
public import bindbc.lua;
import std.traits;

public import engine.scripting.io;
public import engine.scripting.env;
public import engine.scripting.state;
public import engine.scripting.tools;
public import engine.scripting.reg;
public import engine.scripting.script;
public import engine.scripting.utils;
public import engine.scripting.engine;

package(engine) {
    LuaSupport initScripting() {
        return loadLua();
    }
}
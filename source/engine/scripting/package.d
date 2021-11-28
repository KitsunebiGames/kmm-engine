module engine.scripting;
public import bindbc.lua;
import std.traits;

public import engine.scripting.io;
public import engine.scripting.env;
public import engine.scripting.state;
public import engine.scripting.tools;

package(engine) {
    void initScripting() {
        loadLua();
    }
}
/*
    Scripting Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.scripting;
public import engine.scripting.script;
public import as;
import as.addons.str;


/**
    State of scripting engine
*/
ScriptEngine ScriptState;

static this() {

    // Create the script state
    ScriptState = ScriptEngine.create();
    
    // Set up script state and pool
    ScriptExec = ScriptState.createContext();

    // We want D string support.
    ScriptState.registerDStrings();
}
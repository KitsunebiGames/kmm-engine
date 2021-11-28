module engine.scripting.script;
import engine;

private {
    KMScript[string] scripts;
}

/**
    Sets a script in the script store
*/
void kmScriptStoreSet(string name, KMScript script) {
    scripts[name] = script;
    scripts[name].name = name;
}

/**
    Remove script from script store
*/
void kmScriptStoreRemove(string name) {
    scripts.remove(name);
}

/**
    Gets a script in the scriptstore
*/
KMScript* kmScriptStoreGet(string name) {
    return name in scripts;
}

/**
    Allows scripts to be iterated over.
*/
ref KMScript[string] kmScriptStoreGetIterator() {
    return scripts;
}

enum ScriptType { 
    Invalid, 
    Source, 
    Bytecode
}

/**
    A script
*/
struct KMScript {

    /**
        Name of the script
    */
    string name;

    /**
        Type of the script
    */
    ScriptType type;

    union {
        /**
            The source code of the script
        */
        string source;

        /**
            The bytecode of the script
        */
        ubyte[] bytecode;
    }

    /**
        Creates a sourcode based script
    */
    this(string source) {
        this.type = ScriptType.Source;
        this.source = source;
    }

    /**
        Creates a bytecode based script
    */
    this(ubyte[] bytecode) {
        this.type = ScriptType.Bytecode;
        this.bytecode = bytecode;
    }

    /**
        Gets whether the script is source text based
    */
    bool isSource() {
        return type == ScriptType.Source;
    }

    /**
        Gets whether the script is bytecode based
    */
    bool isBytecode() {
        return type == ScriptType.Source;
    }

    /**
        Gets whether the script can be edited
    */
    bool canEdit() {
        return type == ScriptType.Source;
    }

    void load(lua_State* state) {
        if (type == ScriptType.Source) {
            kmLuaLoad(state, source);
        } else {
            kmLuaLoad(state, name, bytecode);
        }
    }
}
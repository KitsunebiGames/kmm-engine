module engine.scripting.script;
import as;
import std.exception;
import std.format;

/**
    The script context
*/
public ScriptContext ScriptExec;

/*
    Script stats
*/
private int loadedScripts;
public int getScriptCount() {
    return loadedScripts;
}

/**
    The type of a script
*/
enum ScriptType {
    /**
        Editable code, stored as a string
    */
    Editable,

    /**
        Script bytecode
    */
    Bytecode,

    /**
        Script with both bytecode and string code loaded.
    */
    Multi
}

/**
    A script
*/
class Script {
private:
    ScriptEngine engine;
    ScriptType type;

    string code;
    ubyte[] bytecode;

    // Cached generated module so we don't overwrite
    Module generatedModule;

    // Module pre-generation code
    void pregenerate() {

        // We don't allow overwriting modules
        enforce(engine.getModule(name) is null, "Attempted to overwrite module '%s'".format(name));

        generatedModule = engine.getModule(name, ModuleCreateFlags.CreateIfNotExists);
        switch(type) {
            
            // For bytecode based scripts we should prefer to load the bytecode first
            case ScriptType.Multi:
            case ScriptType.Bytecode:
                generatedModule.loadByteCode(bytecode);
                break;

            //
            case ScriptType.Editable:
                generatedModule.addScriptSection("code", code);
                generatedModule.build();
                break;

            // We'll never hit this case, but...
            default: assert(0);
        }
    }

public:
    /**
        Name of the script
    */
    immutable(string) name;

    /**
        Gets the type of the script
    */
    ScriptType getType() {
        return type;
    }

    ~this() {
        loadedScripts--;
    }

    /**
        Creates script from bytecode with supplementary text code
    */
    this(ScriptEngine engine, string name, string code, ubyte[] bytecode) {
        this.engine = engine;
        this.name = name;
        this.code = code;
        this.bytecode = bytecode;
        this.type = ScriptType.Multi;

        loadedScripts++;
    }

    /**
        Creates script from text code
    */
    this(ScriptEngine engine, string name, string code) {
        this.engine = engine;
        this.name = name;
        this.code = code;
        this.type = ScriptType.Editable;

        loadedScripts++;
    }

    /**
        Creates script from bytecode
    */
    this(ScriptEngine engine, string name, ubyte[] bytecode) {
        this.engine = engine;
        this.name = name;
        this.bytecode = bytecode;
        this.type = ScriptType.Bytecode;
        
        loadedScripts++;
    }

    /**
        Sets the code for the script if possible    
    */
    void setCode(string code) {
        enforce(type != ScriptType.Bytecode, "Unsafe code change operation unsupported");

        // Pre-generate the module if needed
        if (generatedModule is null) {

            // We don't allow overwriting modules
            enforce(engine.getModule(name) is null, "Attempted to overwrite module '%s'".format(name));
            generatedModule = engine.getModule(name, ModuleCreateFlags.CreateIfNotExists);
        }

        // Update the code for the module
        generatedModule.addScriptSection("code", code);
        generatedModule.build();
    }

    /**
        Gets the module
    */
    Module getModule() {
        
        // If not cached yet, cache our script
        if (generatedModule is null) pregenerate();

        return generatedModule;
    }
}
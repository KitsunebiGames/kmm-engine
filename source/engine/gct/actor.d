module engine.gct.actor;
import engine;

enum KMObjectFlag : ubyte {
    None        = 0b00000000,
}

/**
    A game object
*/
@KMLuaBind("_ACTORS")
struct KMActor {
public:
    ~this() {
        kmLuaRelease(kmWorldState, initFuncRef);
        kmLuaRelease(kmWorldState, updateFuncRef);
        kmLuaRelease(kmWorldState, drawFuncRef);
    }

    // SCRIPT FUNCTIONS
    int initFuncRef;
    int updateFuncRef;
    int drawFuncRef;

    /**
        The ID of this game object
    */
    uint id;

    /**
        Script attached to this object
    */
    string script;

    /**
        Flags for the game object
    */
    KMObjectFlag flags;

    /**
        The position of the game object
    */
    vec2 position;
    
}
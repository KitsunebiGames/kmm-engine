module engine.gct.gameobject;
import engine;

enum KMObjectFlag : ubyte {
    None        = 0b00000000,
    IsPlayer    = 0b00000001,
}

/**
    Create a reference of the game object 
*/
void kmGameObjectCreateRef(lua_State* state, KMGameObject* obj) {
}

/**
    A game object
*/
@KMLuaBind("_GAMEOBJECTS")
struct KMGameObject {
    
    /**
        Automatically destroy game object when no longer referenced
    */
    ~this() {
        kmLuaDestroyEntity(state, this);
    }
    
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

    /**
        Adds this game object to the engine
    */
    void registerGameObject(lua_State* state) {
        kmLuaRegisterEntity!KMGameObject(state, this);
    }
}
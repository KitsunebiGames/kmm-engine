module game.entity;
import containers.list;
import engine;
import game.itr;

/**
    List of alive entities in the game
*/
public __gshared List!Entity Entities;

/**
    Spawns an entity
*/
void spawnEntity(Entity entity, vec2i at) {
    entity.position = at;
    Entities ~= entity;
}

/**
    Collects entities
*/
void collectEntities() {
    for(int i = 0; i < Entities.count; i++) {
        if (Entities[i].collect) Entities.removeAt(i);
        i--;
    }
}

/**
    An entity

    Script functions are as follows:

    void onInit(Entity@ self)
    void onUpdate(Entity@ self)
    void onPostUpdate(Entity@ self)
    void onDeath(Entity@ self)
    void onCollission(Entity@ self, Entity@ other)
*/
class Entity {
private:

    // Script function definitions
    Function onInitFunc;
    void execOnInit() {
        if (onInitFunc !is null) {
            ScriptExec.prepare(onInitFunc);
            ScriptExec.setArgObject(0, cast(void*)this);
            ScriptExec.execute();
        }
    }

    Function onUpdateFunc;
    void execUpdateFunc() {
        if (onInitFunc !is null) {
            ScriptExec.prepare(onUpdateFunc);
            ScriptExec.setArgObject(0, cast(void*)this);
            ScriptExec.execute();
        }
    }

    Function onPostUpdateFunc;
    void execPostUpdate() {
        if (onInitFunc !is null) {
            ScriptExec.prepare(onPostUpdateFunc);
            ScriptExec.setArgObject(0, cast(void*)this);
            ScriptExec.execute();
        }
    }

    Function onDeathFunc;
    void execDeath() {
        if (onInitFunc !is null) {
            ScriptExec.prepare(onDeathFunc);
            ScriptExec.setArgObject(0, cast(void*)this);
            ScriptExec.execute();
        }
    }

    Function onCollissionFunc;
    void execOnCollission(Entity* other) {
        if (onCollissionFunc !is null) {
            ScriptExec.prepare(onCollissionFunc);
            ScriptExec.setArgObject(0, cast(void*)this);
            ScriptExec.setArgObject(1, other);
            ScriptExec.execute();
        }
    }

    void loadFunctions() {
        Module mod = script.getModule();
        onInitFunc = mod.getFunctionByDecl("void onInit(Entity@ self)");
        onUpdateFunc = mod.getFunctionByDecl("void onUpdate(Entity@ self)");
        onPostUpdateFunc = mod.getFunctionByDecl("void onPostUpdate(Entity@ self)");
        onDeathFunc = mod.getFunctionByDecl("void onDeath(Entity@ self)");
        onCollissionFunc = mod.getFunctionByDecl("void onCollission(Entity@ self, Entity@ other)");

        AppLog.info("Entity", "%s function register is: init=%s update=%s death=%s", name, onInitFunc, onUpdateFunc, onDeathFunc);

    }

public:
    this(string name, Script script, vec2i position) {
        this.name = name;
        this.script = script;
        this.position = position;

        loadFunctions();
        execOnInit();
    }

    /**
        The script this entity executes
    */
    Script script;

    /**
        Gets name of entity
    */
    string name;

    /**
        Position of the entity
    */
    vec2i position;

    /**
        Whether this entity should be collected
    */
    bool collect = false;

    /**
        Whether the entity is alive
    */
    bool alive = true;

    /**
        Whether screen transitions should affect the entity
    */
    bool persistent = false;

    void update() {
        execUpdateFunc();
    }

    void postUpdate() {
        execPostUpdate();
    }
}

/**
    Gets total count of entities
*/
int totalEntities() {
    return cast(int)Entities.count;
}

/**
    Finds the entity with specified name
*/
Iterator!(Entity)* findEntity(ref string name) {
    Iterator!(Entity)* iter = new Iterator!Entity;

    foreach(entity; Entities) {
        if (entity.name == name) iter.add(&entity);
    }

    return iter;
}

/**
    Registers the entity type and helper functions
*/
void registerEntityType(ScriptEngine engine) {

    // Register entity
    engine.registerObjectType("Entity", Entity.sizeof, TypeFlags.Ref | TypeFlags.NoCount);
    
    // Register the iterators we need
    registerIterator!Entity(engine);

    // Global functions
    engine.registerGlobalFunction("EntityIter@ findEntity(string name)", &findEntity);

    // Register entity properties
    engine.registerObjectProperty("Entity", "bool alive", Entity.alive.offsetof);
    
    // FIXME: Why does this cause a segfault?
    //AppLog.info("Script Engine", "Registered Entity...");
}
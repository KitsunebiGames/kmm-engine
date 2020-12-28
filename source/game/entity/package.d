module game.entity;
public import game.entity.player;
public import game.entity.escript;
import containers.list;
import engine;
import game.itr;

/**
    The global instance of the player
*/
public __gshared Player ThePlayer;

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
    ScriptContext iContext;

    ref ScriptContext getActiveContext() {

        // The entity has its own context
        if (iContext !is null) return iContext;

        // The entity uses the global context
        return ScriptExec;
    }

public:

    /**
        Destructor
    */
    ~this() {
        // We want this to be collected once this entity is destroyed
        if (iContext !is null) destroy(iContext);
    }

    /**
        Creates a new entity
    */
    this(string name, Script script, vec2i position, bool hasOwnContext) {
        this.name = name;
        this.position = position;

        // Allow entities to have their own context
        if (hasOwnContext) iContext = ScriptState.createContext();

        if (script !is null) {
            this.script = new EntityScript(this, script);
            this.script.loadFunctions();
            this.script.onInit();
        }
    }

    /**
        The scripts attached to the entity
    */
    EntityScript script;

    /**
        Gets name of entity
    */
    string name;

    /**
        The health of the entity
    */
    int health;

    /**
        Whether the entity is immortal
    */
    bool immortal;

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
        Update function
    */
    void update() {
        if (script !is null) script.onUpdate();
    }

    /**
        Post update function
    */
    void postUpdate() {
        if (script !is null) script.onPostUpdate();
    }

    /**
        Destroys this entity
    */
    void destroy_() {
        this.collect = true;
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
    Gets the player
*/
Entity getPlayer() {
    return ThePlayer;
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
    engine.registerGlobalFunction("Entity@ getPlayer()", &getPlayer);

    // Register entity properties
    engine.registerObjectProperty("Entity", "bool alive", Entity.alive.offsetof);
    engine.registerObjectProperty("Entity", "int health", Entity.health.offsetof);

    // Register entity methods
    engine.registerObjectMethod("Entity", "void destroy()", &Entity.destroy_, DCallObjLast);
    
    // FIXME: Why does this cause a segfault?
    //AppLog.info("Script Engine", "Registered Entity...");
}
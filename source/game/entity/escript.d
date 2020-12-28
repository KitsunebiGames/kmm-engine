module game.entity.escript;
import game.entity;
import engine;

/**
    A script attached to an entity
*/
class EntityScript {
private:
    Entity entity;
    Script script;
    ScriptContext iContext;

    // Script function definitions
    Function onInitFunc;
    void execOnInit() {
        if (onInitFunc !is null) {
            iContext.prepare(onInitFunc);
            iContext.setArgObject(0, cast(void*)entity);
            iContext.execute();
        }
    }

    Function onUpdateFunc;
    void execUpdateFunc() {
        if (onUpdateFunc !is null) {
            iContext.prepare(onUpdateFunc);
            iContext.setArgObject(0, cast(void*)entity);
            iContext.execute();
        }
    }

    Function onPostUpdateFunc;
    void execPostUpdate() {
        if (onPostUpdateFunc !is null) {
            iContext.prepare(onPostUpdateFunc);
            iContext.setArgObject(0, cast(void*)entity);
            iContext.execute();
        }
    }

    Function onDeathFunc;
    void execDeath() {
        if (onDeathFunc !is null) {
            iContext.prepare(onDeathFunc);
            iContext.setArgObject(0, cast(void*)entity);
            iContext.execute();
        }
    }

    Function onCollissionFunc;
    void execOnCollission(Entity other) {
        if (onCollissionFunc !is null) {
            iContext.prepare(onCollissionFunc);
            iContext.setArgObject(0, cast(void*)entity);
            iContext.setArgObject(1, cast(void*)other);
            iContext.execute();
        }
    }

public:

    /**
        Loads the script functions
    */
    void loadFunctions() {
        Module mod = script.getModule();
        onInitFunc = mod.getFunctionByDecl("void onInit(Entity@ self)");
        onUpdateFunc = mod.getFunctionByDecl("void onUpdate(Entity@ self)");
        onPostUpdateFunc = mod.getFunctionByDecl("void onPostUpdate(Entity@ self)");
        onDeathFunc = mod.getFunctionByDecl("void onDeath(Entity@ self)");
        onCollissionFunc = mod.getFunctionByDecl("void onCollission(Entity@ self, Entity@ other)");
    }

    /**
        Instantiates entity script
    */
    this(Entity entity, Script script) {
        this.entity = entity;
        this.script = script;
    }

    /**
        Executes onInit
    */
    void onInit() {
        execOnInit();
    }

    /**
        executes onUpdate
    */
    void onUpdate() {
        execUpdateFunc();
    }

    /**
        executes onPostUpdate
    */
    void onPostUpdate() {
        execPostUpdate();
    }

    /**
        executes onDeath
    */
    void onDeath() {
        execDeath();
    }

    /**
        executes onCollission
    */
    void onCollission(Entity other) {
        execOnCollission(other);
    }
}
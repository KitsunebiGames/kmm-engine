module engine.scripting;
public import bindbc.lua;
import std.traits;

package(engine) {
    void initScripting() {
        loadLua();
    }

    class SharedState {
    protected:
        lua_State* state;

    public:
        lua_State* getState() {
            return state;
        }

        /**
            Pushes a string on to the stack
        */
        void push(string text) {
            lua_pushlstring(state, text.ptr, text.length);
        }

        /**
            Pushes an unsigned number to the stack
        */
        void push(T)(T number) if (!is(T == bool) && isUnsigned!T) {
            lua_pushunsigned(state, cast(LUA_UNSIGNED)number);
        }

        /**
            Pushes a number to the stack
        */
        void push(T)(T number) if (!is(T == bool) && isNumeric!T) {
            lua_pushnumber(state, cast(LUA_NUMBER)number);
        }

        /**
            Pushes a boolean value to the stack
        */
        void push(bool value) {
            lua_pushboolean(state, value);
        }
        
    }
}
/**
    A Lua State
*/
class State : SharedState {
public:
    this() {
        state = luaL_newstate();

        // These should be relatively safe
        luaopen_math(state);
        luaopen_utf8(state);
        luaopen_table(state);
        luaopen_coroutine(state);
        luaopen_base(state);
    }

    /**
        Creates a new thread of execution
    */
    ExecutionThread newThread() {
        lua_State* nstate = lua_newthread(state);
        int r = luaL_ref(state, LUA_REGISTRYINDEX);  
        return new ExecutionThread(nstate, r);      
    }

    /**
        Executes a string
    */
    void doString(string str) {
        luaL_dostring(state, str.ptr);
    }

    /**
        Calls a function by name with no arguments
    */
    void call(string func) {
        lua_getglobal(state, func.ptr);
        lua_call(state, 0, 0);
    }
}

/**
    Creates a new execution thread
*/
class ExecutionThread : SharedState  {
private:
    lua_State* state;
    int threadRef;

public:
    this(lua_State* nstate, int threadRef) {
        this.state = nstate;
        this.threadRef = threadRef;
    }

    ~this() {
        luaL_unref(state, LUA_REGISTRYINDEX, threadRef);
    }
}
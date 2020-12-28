module game.itr;
import as;
import std.format;
import core.memory : GC;
import engine;

/**
    An iterator over engine items
*/
struct Iterator(T) {
private:
    size_t i;

    // refcount
    int refCount = 0;

    /**
        Items to iterate over
    */
    T*[] items;

public:

    /**
        Adds item to iterator
    */
    void add(T* item) {
        items ~= item;
    }

    /**
        Adds reference
    */
    void addRef() {
        if (refCount == 0) {
            GC.addRoot(&this);
        }
        refCount++;
    }

    /**
        Releases reference
    */
    void release() {
        refCount--;
        if (refCount == 0) GC.removeRoot(&this);
    }

    /**
        Gets next item
    */
    ref T next() {
        return *items[i++];
    }

    /**
        Gets previous item
    */
    ref T prev() {
        return *items[--i];
    }

    /**
        Get item at position
    */
    ref T at(uint i) {

        // Set new pointer
        this.i = cast(size_t)i;

        // Make sure stuff is in-bounds
        if (i < 0) this.i = 0;
        if (i > items.length) this.i = items.length-1;

        // Get the item
        return *items[this.i];
    }

    /**
        Resets the cursor of the iterator to 0
    */
    void start() {
        i = 0;
    }

    /**
        Moves the cursor to the end of the iterator
    */
    void end() {
        i = items.length;
    }

    /**
        Gets whether the iterator has reached the end
    */
    bool atEnd() {
        return i >= items.length || i < 0;
    }

    /**
        Gets the amount of items in the iterator
    */
    uint count() {
        return cast(uint)items.length;
    }
}

/**
    Registers the entity type and helper functions
*/
void registerIterator(T)(ScriptEngine engine) {
    enum itName = T.stringof~"Iter";
    enum tName = T.stringof;


    engine.registerObjectType(itName, Iterator!T.sizeof, TypeFlags.Ref);
    engine.registerObjectBehaviour(itName, Behaviours.AddRef, "void f()", &Iterator!T.addRef, DCallObjLast);
    engine.registerObjectBehaviour(itName, Behaviours.Release, "void f()", &Iterator!T.release, DCallObjLast);
    engine.registerObjectMethod(itName, "%s@ next()".format(tName), &Iterator!T.next, DCallObjLast);
    engine.registerObjectMethod(itName, "%s@ prev()".format(tName), &Iterator!T.prev, DCallObjLast);
    engine.registerObjectMethod(itName, "%s@ at(uint i)".format(tName), &Iterator!T.at, DCallObjLast);
    engine.registerObjectMethod(itName, "void start()", &Iterator!T.start, DCallObjLast);
    engine.registerObjectMethod(itName, "void end()", &Iterator!T.end, DCallObjLast);
    engine.registerObjectMethod(itName, "bool atEnd()", &Iterator!T.atEnd, DCallObjLast);
    engine.registerObjectMethod(itName, "uint count()", &Iterator!T.count, DCallObjLast);
}
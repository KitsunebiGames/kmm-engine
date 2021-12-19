/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.pak.fmt;
import std.file;
import std.stdio;
import std.exception;
import std.bitmanip;
import std.traits;

/// Kitsunemimi Package Type 0
enum PAK_MAGIC = "FOXPAK_0";

/**
    An entry in the PAK table
*/
struct PakEntry {
    /**
        Item Priority
    */
    ubyte priority;

    /**
        Offset in to file where the content begins (in bytes)
    */
    uint offset;
    
    /**
        Length of content data in bytes
    */
    uint length;

    /**
        Path of resource
    */
    string path;
}

struct PakFile {
private:
    File io;
    PakEntry[string] entries;

    bool checkMagic() {
        ubyte[PAK_MAGIC.length] magic;
        io.rawRead(magic);
        return magic == cast(ubyte[])PAK_MAGIC;
    }

    void readEntries() {
        uint entriesToRead = readInt!uint;
        foreach(i; 0..entriesToRead) {
            PakEntry entry;
            entry.priority = readInt!ubyte;
            entry.offset = readInt!uint;
            entry.length = readInt!uint;
            entry.path = readString(readInt!uint);

            entries[entry.path] = entry;
        }
    }

    /**
        Reads an integer value
    */
    T readInt(T)() if (isIntegral!T) {
        ubyte[T.sizeof] valueBytes;
        io.rawRead(valueBytes);
        return littleEndianToNative!(T, T.sizeof)(valueBytes);
    }

    string readString(size_t length) {
        ubyte[] valueBytes = new ubyte[length];
        io.rawRead(valueBytes);
        return cast(string)valueBytes;
    }

public:

    /**
        Collect file handle on destruction
    */
    ~this() {
        io.close();
    }

    /**
        Opens a PAK file for reading
    */
    this(string file) {
        io = File(file, "rb");
        enforce(this.checkMagic(), "Not a Kitsunemimi PAK file. (Invalid header)");
        this.readEntries();
    }

    /**
        Gets whether a specified resource exists at the specified path
    */
    bool hasResource(string path) {
        return (path in entries) !is null;
    }

    /**
        Gets priority for a resource
    */
    ubyte getPriorityFor(string path) {
        return entries[path].priority;
    }

    /**
        Gets a PAK file resource
    */
    ubyte[] getResource(string path) {
        // Seek to item
        io.seek(entries[path].offset);
        
        // Read data
        ubyte[] data = new ubyte[entries[path].length];
        io.rawRead(data);

        // Return data
        return data;
    }
}
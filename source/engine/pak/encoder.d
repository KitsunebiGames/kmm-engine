/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.pak.encoder;
import engine.pak.fmt;
import std.file;
import std.stdio;
import std.path;
import std.bitmanip;

/**
    A binding from a Pak entry to a physical file.
*/
struct PakEntryBinding {
    PakEntry entry;
    string file;
}

/**
    Writes pak entries in to a new file
*/
void kmPakWriteToFile(PakEntryBinding[] bindings, string file) {
    File writer = File(file, "wb");
    File reader;
    PakEntryBinding[size_t] offsetBindings;
    
    // Write magic bytes
    writer.rawWrite(PAK_MAGIC);

    // Write entry table count
    writer.rawWrite(nativeToLittleEndian!uint(bindings.length));

    foreach(binding; bindings) {
        auto entry = DirEntry(binding.file);

        // Write priority
        writer.rawWrite([binding.entry.priority]);

        // Updat binding list
        offsetBindings[writer.tell()] = binding;

        // numeric stuff
        writer.rawWrite([
            nativeToLittleEndian!uint(0u), // placeholder for data offset
            nativeToLittleEndian!uint(entry.size()), // data length
            nativeToLittleEndian!uint(binding.entry.path.length) // length of path name
        ]);

        // Write path
        writer.rawWrite(cast(ubyte[])binding.entry.path);
    }

    foreach(boff, binding; offsetBindings) {
        reader = File(binding.file, "rb");

        // Set the offset
        writer.seek(boff);
        writer.rawWrite([nativeToLittleEndian!uint(writer.tell())]);

        // write the contents
        ubyte[] fileData = new ubyte[binding.entry.length];
        reader.rawRead(fileData);
        writer.rawWrite(fileData);

        // We're done reading the contents in this iteration
        reader.close();
    }

    // We're done.
    writer.close();
}
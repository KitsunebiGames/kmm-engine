/*
    Content packages subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.pak;
import engine.pak.fmt;
public import engine.pak.encoder;

import engine;
import std.exception;
import std.format;
import std.file;
import std.path;

private {
    PakFile[] loadedFiles;
    int failedLoads;
}

/**
    Initializes package loader
*/
void kmPakInit() {

    // Make sure kmpack folder exists
    if (!exists("kmpack")) mkdir("kmpack");

    // Iterate over entries
    foreach(DirEntry entry; dirEntries("kmpack", "*.pak", SpanMode.breadth, false)) {
        
        // Skip directories and symbolic links,
        // they're technically both files, but not PAK files.
        // That and we don't want someone to make a rouge symlink
        // which freezes the application.
        if (entry.isDir() || entry.isSymlink()) continue;

        try {
            // Add file to entries
            loadedFiles ~= PakFile(entry.name());
        } catch (Exception ex) {
            AppLog.warn("Engine", "Failed to load content package '%s'".format(entry.name()));
            failedLoads++;
        }
    }

    AppLog.info("Engine", "Loaded %s content packages...", loadedFiles.length);
}

/**
    Get how many packages that were loaded
*/
int kmPakGetCount() {
    return loadedFiles.length;
}

/**
    Gets how many packages that failed to load
*/
int kmPakGetFailed() {
    return failedLoads;
}

/**
    Gets a resource for the specified path
*/
ubyte[] kmPakGetResource(string path) {
    ptrdiff_t element = -1;
    ubyte highestPriority = 0;

    // Seek for the highest priority element with the specified path
    // This allows PAK files to overwrite each other, allowing for DLC
    foreach(i, pakFile; loadedFiles) {
        if (pakFile.hasResource(path)) {
            auto priority = pakFile.getPriorityFor(path);
            if (priority > highestPriority) {
                highestPriority = priority;
                element = i;
            }
        }
    }

    // Make sure element exists
    enforce(element >= 0, "No resource found at path '%s'".format(path));

    // Return resource
    return loadedFiles[element].getResource(path);
}
module engine.gct.tile;
import engine;

/**
    flat representation of a tile
*/
struct KMTile {
    ushort type;
    ushort flags;
}

struct GCTTileset {
    /**
        Name of the tileset
    */
    string name;

    /**
        Collission data for a tile
    */
    ubyte[] collissionData;
}
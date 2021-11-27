# Kitsunemimi Engine
A game engine optimized for making metroidvania games.

## Dependencies
The Kitsunemimi engine requires the following dependencies to be present to work:
 * OpenAL Driver ([OpenAL-Soft included on Windows](https://github.com/kcat/openal-soft))
 * OpenGL Driver
 * SDL2 2.0.12 or above
 * FreeType
 * AngelScript (Precompiled patched version with D support)
 * Kosugi Maru Font (in [`res/fonts`](/res/fonts) w/ license)
 * PixelMPlus 10 Font (in [`res/fonts`](/res/fonts) w/ license)

On Windows these libraries are copied from the included libs/ folder.

## Compiling with LDC2
Compilation will fail with LDC2 on Windows due to difficulty finding the library files to link against,  
take the lib files from dangel and drop them in to this project's lib folder for LDC2 to work.
# Kitsunemimi Engine
A game engine optimized for making metroidvania games.

&nbsp;  
&nbsp;  

## Why Kitsunemimi Engine?
**Why not?**  
I personally find that making games in your own engine makes the experience a whole lot more fun.  
Granted this is not for everyone, but as this engine is extensible and uses scripting for game mechanics,  
you could use this engine to make games within without having to write the engine, with some "caveats"

### Caveats
 * No builtin DRM, I despise it.
 * No asset encryption, though assets are bundled in to packages.
 * No currently existing support for games consoles.
 * Single-threaded, except for audio playback. (At least until potential bgfx renderer rewrite)
 * Still under semi-active development.

&nbsp;  
&nbsp;  

## Dependencies
The Kitsunemimi engine requires the following dependencies to be present to work:
 * OpenAL Driver ([OpenAL-Soft included on Windows](https://github.com/kcat/openal-soft))
   * Driver REQUIRES support for the FLOAT32 OAL extension and audio files may only be mono or stereo.
 * OpenGL Driver
 * SDL2 2.0.12 or above
 * FreeType
 * AngelScript (Precompiled patched version with D support)
 * Kosugi Maru Font (in [`res/fonts`](/res/fonts) w/ license)
 * PixelMPlus 10 Font (in [`res/fonts`](/res/fonts) w/ license)

On Windows these libraries are copied from the included libs/ folder.

&nbsp;  
&nbsp;  

## Compiling with LDC2
Compilation will fail with LDC2 on Windows due to difficulty finding the library files to link against,  
take the lib files from dangel and drop them in to this project's lib folder for LDC2 to work.
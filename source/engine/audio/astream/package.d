/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.audio.astream;
import af = audioformats;
import std.path;
import bindbc.openal;
import std.format;
import std.range;

/**
    A stream of audio
*/
class AudioStream {
private:
    // Backend stream
    af.AudioStream* bStream;

    bool fromFile;
    string file;
    ubyte[] data;

public:
    /**
        Reads all samples for a file
    */
    float[] readAllSamples() {
        float[] readBuffer;
        float[4096] tempBuff;
        while(true) {
            int read = bStream.readSamplesFloat(tempBuff.ptr, tempBuff.length/2);
            readBuffer ~= tempBuff[0..read*channels()];
            if (read <= 0) break;
        }
        return readBuffer;
    }

    /**
        Opens an audio stream from memory
    */
    this(ubyte[] memory) {
        bStream = new af.AudioStream;
        this.data = memory;
        this.fromFile = false;
        bStream.openFromMemory(memory);
    }

    /**
        Opens an audio stream from file
    */
    this(string file) {
        bStream = new af.AudioStream;
        this.file = file;
        this.fromFile = true;
        bStream.openFromFile(file);
    }

    /**
        The amount of channels in the audio stream
    */
    int channels() { return bStream.getNumChannels(); }

    /**
        Read samples from the audio stream in to the array

        Returns the amount of samples read
        Returns 0 if there's no more samples
    */
    ptrdiff_t readSamples(ref float[] toArray) {
        return cast(int)bStream.readSamplesFloat(toArray.ptr, cast(int)(toArray.length/channels))*channels;
    }

    /**
        Read samples from the audio stream in to the array

        Returns the amount of samples read
        Returns 0 if there's no more samples
    */
    ptrdiff_t readSamples(float* toArray, int samples) {
        return bStream.readSamplesFloat(toArray, cast(int)(samples/channels))*channels;
    }

    /**
        Seek to a PCM location in the stream
    */
    void seek(size_t location) {
        bStream.seekPosition(cast(int)location/channels);
    }

    bool canSeek() {
        final switch(bStream.getFormat()) with (af.AudioFileFormat)
        {
            case wav:     return true;
            case mp3:     return true;
            case flac:    return true;
            case ogg:     return false;
            case opus:    return true;
            case mod:     return false;
            case xm:      return false;
            case unknown: return false;
        }
    }

    /**
        Get the position in the stream
    */
    size_t tell() { return 0; }

    /**
        Gets the OpenAL format of the audio stream
    */
    ALenum format() {
        return channels == 1 ? AL_FORMAT_MONO_FLOAT32 : AL_FORMAT_STEREO_FLOAT32;
    }

    /**
        Returns the file format of the stream
    */
    string fileFormat() {
        return af.convertAudioFileFormatToString(bStream.getFormat());
    }

    /**
        Gets the sample rate of the stream
    */
    int samplerate() { return cast(int)bStream.getSamplerate(); }

    /**
        Rewinds the audio stream
    */
    void rewind() {
        if (canSeek) {
            seek(0);
        } else {
            import dplug.core : destroyFree;
            destroyFree(bStream);

            bStream = new af.AudioStream;
            if (fromFile) bStream.openFromFile(file);
            else bStream.openFromMemory(data);
        }
    }
}
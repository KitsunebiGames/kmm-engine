/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.audio.mixer;
import engine.core;
import engine.math;

private float mainGain;
private float[string] channelGains;

/**
    Sets the gain of the main channel
*/
void kmMixerSetGain(float gain) {
    mainGain = clamp(gain, 0, 1);
}

/**
    Gets whether the mixer has a channel with the specified name
*/
bool kmMixerHasChannel(string name) {
    return (name in channelGains) !is null;
}

/**
    Gets a list of channels in the mixer
*/
string[] kmMixerChannels() {
    return channelGains.keys;
}

/**
    Creates an audio channel
*/
void kmMixerCreateChannel(string name) {
    channelGains[name] = 1;
}

/**
    Sets the gain of the specified channel
*/
void kmMixerSetGain(string name, float gain) {
    
    // We won't allow overdrive of the volume
    gain = clamp(gain, 0, 1);

    switch(name) {
        case "Main", "main", null:
            mainGain = gain;
            return;

        default:
            channelGains[name] = gain;
            return;
    }
}

/**
    Gets the gain for the specified channel, default is Main
*/
float kmMixerGetGainFor(string name="Main") {
    switch(name) {
        case "Main", "main", null:
            return mainGain;

        default:
            // If the channel is not in the channel list we'll just return the main gain
            if (name !in channelGains) return mainGain;

            // When we get an individual channel gain we want to apply the main gain so that the main gain actually works.
            return clamp(channelGains[name]*mainGain, 0, 1);
    }
}
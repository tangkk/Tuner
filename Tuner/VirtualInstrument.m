//
//  AUGraphConsole.m
//  Tuner
//
//  Created by tangkk on 18/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

/* Some of the code here are copied from sample code LoadPresetDemo
 provided by Apple Inc.
 */

// TODO: Stop Playing notes

#import "VirtualInstrument.h"
#import "MIDInote.h"
#import <AssertMacros.h>

@interface VirtualInstrument()
@property (readwrite) Float64   graphSampleRate;
@property (readwrite) AUGraph   processingGraph;
@property (readwrite) AudioUnit samplerUnit_1;
@property (readwrite) AudioUnit samplerUnit_2;
@property (readwrite) AudioUnit samplerUnit_3;
@property (readwrite) AudioUnit samplerUnit_4;
@property (readwrite) AudioUnit samplerUnit_5;
@property (readwrite) AudioUnit samplerUnit_6;
@property (readwrite) AudioUnit samplerUnit_7;
@property (readwrite) AudioUnit ioUnit;
@property (readwrite) AudioUnit mixerUnit;

@property (readwrite) UInt8 currentPlayingNote;

- (OSStatus)    loadSynthFromPresetURL:(NSURL *) presetURL withInstrumentID:(UInt8)InstrID;
- (void)        registerForUIApplicationNotifications;
- (BOOL)        createAUGraph;
- (void)        configureAndStartAudioProcessingGraph: (AUGraph) graph;
- (void)        stopAudioProcessingGraph;
- (void)        restartAudioProcessingGraph;

@end

@implementation VirtualInstrument

-(id)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    // Set up the audio session for this app, in the process obtaining the
    // hardware sample rate for use in the audio processing graph.
    BOOL audioSessionActivated = [self setupAudioSession];
    NSAssert (audioSessionActivated == YES, @"Unable to set up audio session.");
    
    // Create the audio processing graph; place references to the graph and to the Sampler units
    // into the processingGraph and samplerUnits instance variables.
    [self createAUGraph];
    [self configureAndStartAudioProcessingGraph: self.processingGraph];
    
    [self registerForUIApplicationNotifications];
    
    // Load a default musical instrument
    //[self setInstrument:@"Guitar"];
    
    return self;
}

- (void)playMIDI:(MIDINote *)MIDINote withInstrumentID:(UInt8)InstrID{
    self.currentPlayingNote = MIDINote.note;
    if (MIDINote) {
        UInt32 noteNum = MIDINote.note;
        UInt32 onVelocity = MIDINote.velocity;
        UInt32 noteCommand = 	MIDINote.Root;
        
        OSStatus result = noErr;
        
        switch (InstrID) {
            case Trombone:
                result = MusicDeviceMIDIEvent (self.samplerUnit_1, noteCommand, noteNum, onVelocity, 0);
                break;
                
            case Loop:
                result = MusicDeviceMIDIEvent (self.samplerUnit_2, noteCommand, noteNum, onVelocity, 0);
                break;
                
            case MuteElecGuitar:
                result = MusicDeviceMIDIEvent (self.samplerUnit_3, noteCommand, noteNum, onVelocity, 0);
                break;
                
            case Guitar:
                result = MusicDeviceMIDIEvent (self.samplerUnit_4, noteCommand, noteNum, onVelocity, 0);
                break;
                
            case Ensemble:
                result = MusicDeviceMIDIEvent (self.samplerUnit_5, noteCommand, noteNum, onVelocity, 0);
                break;
                
            case Piano:
                result = MusicDeviceMIDIEvent (self.samplerUnit_6, noteCommand, noteNum, onVelocity, 0);
                break;
                
            case Vibraphone:
                result = MusicDeviceMIDIEvent (self.samplerUnit_7, noteCommand, noteNum, onVelocity, 0);
                break;
                
            default:
                break;
        }
        
        
        NSCAssert (result == noErr, @"Unable to play. Error code: %d '%.4s'\n", (int) result, (const char *)&result);
    }
}

- (void)stopMIDI:(UInt8) note {
    if(note) {
        UInt32 noteNum = note;
        UInt32 offVelocity = 0;
        UInt32 noteCommand = kMIDINoteOff << 4 | 0;
        
        OSStatus result = noErr;
        result = MusicDeviceMIDIEvent(self.samplerUnit_1, noteCommand, noteNum, offVelocity, 0);
        result = MusicDeviceMIDIEvent(self.samplerUnit_2, noteCommand, noteNum, offVelocity, 0);
        result = MusicDeviceMIDIEvent(self.samplerUnit_3, noteCommand, noteNum, offVelocity, 0);
        result = MusicDeviceMIDIEvent(self.samplerUnit_4, noteCommand, noteNum, offVelocity, 0);
        result = MusicDeviceMIDIEvent(self.samplerUnit_5, noteCommand, noteNum, offVelocity, 0);
        result = MusicDeviceMIDIEvent(self.samplerUnit_6, noteCommand, noteNum, offVelocity, 0);
        result = MusicDeviceMIDIEvent(self.samplerUnit_7, noteCommand, noteNum, offVelocity, 0);
        
        NSCAssert(result == noErr, @"Unable to stop. Error code: %d '%.4s'\n", (int) result, (const char *)&result);
    }
}

// Load AUPreset to setup the current instrument
- (void)setInstrument:(NSString *)InstrumentName withInstrumentID:(UInt8)InstrID{
    NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:InstrumentName ofType:@"aupreset"]];
	if (presetURL) {
		NSLog(@"Attempting to load preset '%@'\n", [presetURL description]);
        //self.currentPresetLabel.text = InstrumentName;	}
        self.currentPresetLabel = InstrumentName;   }
	else {
		NSLog(@"COULD NOT GET PRESET PATH!");
	}
    
	[self loadSynthFromPresetURL: presetURL withInstrumentID:InstrID];
}

#pragma mark -
#pragma mark Audio setup

// Create an audio processing graph.
- (BOOL) createAUGraph {
    
	OSStatus result = noErr;
	AUNode samplerNode_1, samplerNode_2, samplerNode_3, samplerNode_4, samplerNode_5, samplerNode_6, samplerNode_7;
    AUNode mixerNode, ioNode;
    
    // Specify the common portion of an audio unit's identify, used for both audio units
    // in the graph.
	AudioComponentDescription cd = {};
	cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
	cd.componentFlags            = 0;
	cd.componentFlagsMask        = 0;
    
    // Multichannel mixer unit
    AudioComponentDescription MixerUnitDescription;
    MixerUnitDescription.componentType          = kAudioUnitType_Mixer;
    MixerUnitDescription.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    MixerUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    MixerUnitDescription.componentFlags         = 0;
    MixerUnitDescription.componentFlagsMask     = 0;
    
    // Instantiate an audio processing graph
	result = NewAUGraph (&_processingGraph);
    NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	//Specify the Sampler unit, to be used as the first node of the graph
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
	
    // Add the Sampler unit nodes to the graph
	result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode_1);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode_2);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode_3);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode_4);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode_5);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode_6);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode_7);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Specify the Output unit, to be used as the second and final node of the graph
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
    // Add the Output unit node to the graph
	result = AUGraphAddNode (self.processingGraph, &cd, &ioNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphAddNode (self.processingGraph, &MixerUnitDescription, &mixerNode);
    
    NSCAssert (result == noErr, @"AUGraphNewNode failed for Mixer unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Open the graph
	result = AUGraphOpen (self.processingGraph);
    NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphConnectNodeInput (self.processingGraph, mixerNode, 0, ioNode, 0);
    NSCAssert (result == noErr, @"AUGraphConnectNodeInput. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Connect the Sampler units to the output unit
	result = AUGraphConnectNodeInput (self.processingGraph, samplerNode_1, 0, mixerNode, 0);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	result = AUGraphConnectNodeInput (self.processingGraph, samplerNode_2, 0, mixerNode, 1);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphConnectNodeInput (self.processingGraph, samplerNode_3, 0, mixerNode, 2);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphConnectNodeInput (self.processingGraph, samplerNode_4, 0, mixerNode, 3);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphConnectNodeInput (self.processingGraph, samplerNode_5, 0, mixerNode, 4);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphConnectNodeInput (self.processingGraph, samplerNode_6, 0, mixerNode, 5);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphConnectNodeInput (self.processingGraph, samplerNode_7, 0, mixerNode, 6);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the Sampler unit from its node
	result = AUGraphNodeInfo (self.processingGraph, samplerNode_1, 0, &_samplerUnit_1);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo (self.processingGraph, samplerNode_2, 0, &_samplerUnit_2);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo (self.processingGraph, samplerNode_3, 0, &_samplerUnit_3);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo (self.processingGraph, samplerNode_4, 0, &_samplerUnit_4);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo (self.processingGraph, samplerNode_5, 0, &_samplerUnit_5);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo (self.processingGraph, samplerNode_6, 0, &_samplerUnit_6);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphNodeInfo (self.processingGraph, samplerNode_7, 0, &_samplerUnit_7);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the I/O unit from its node
	result = AUGraphNodeInfo (self.processingGraph, ioNode, 0, &_ioUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AUGraphNodeInfo (self.processingGraph, mixerNode, NULL, &_mixerUnit);
    
    NSCAssert (result == noErr, @"AUGraphNodeInfo. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    UInt32 busCount   = 7;    // bus count for mixer unit input
    
    NSLog (@"Setting mixer unit input bus count to: %u", (unsigned int)busCount);
    result = AudioUnitSetProperty (
                                   _mixerUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &busCount,
                                   sizeof (busCount)
                                   );
    NSCAssert (result == noErr, @"AudioUnitSetProperty (set mixer unit bus count). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    return YES;
}

// Starting with instantiated audio processing graph, configure its
// audio units, initialize it, and start it.
- (void) configureAndStartAudioProcessingGraph: (AUGraph) graph {
    
    OSStatus result = noErr;
    UInt32 framesPerSlice = 0;
    UInt32 framesPerSlicePropertySize = sizeof (framesPerSlice);
    UInt32 sampleRatePropertySize = sizeof (self.graphSampleRate);
    
    result = AudioUnitInitialize (self.ioUnit);
    NSCAssert (result == noErr, @"Unable to initialize the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the I/O unit's output sample rate.
    result =    AudioUnitSetProperty (
                                      self.ioUnit,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Obtain the value of the maximum-frames-per-slice from the I/O unit.
    result =    AudioUnitGetProperty (
                                      self.ioUnit,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      &framesPerSlicePropertySize
                                      );
    
    NSCAssert (result == noErr, @"Unable to retrieve the maximum frames per slice property from the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AudioUnitSetProperty (
                                   self.mixerUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &framesPerSlice,
                                   framesPerSlicePropertySize
                                   );
    
    NSCAssert (result == noErr, @"AudioUnitSetProperty (set mixer unit input stream format). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AudioUnitSetProperty (
                                   self.mixerUnit,
                                   kAudioUnitProperty_SampleRate,
                                   kAudioUnitScope_Output,
                                   0,
                                   &_graphSampleRate,
                                   sampleRatePropertySize
                                   );
    
    NSCAssert (result == noErr, @"AudioUnitSetProperty (set mixer unit output stream format). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the Sampler unit's output sample rate.
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_1,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the Sampler unit's maximum frames-per-slice.
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_1,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_2,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_2,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_3,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_3,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_4,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_4,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_5,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_5,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_6,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_6,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_7,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result =    AudioUnitSetProperty (
                                      self.samplerUnit_7,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    
    if (graph) {
        
        // Initialize the audio processing graph.
        result = AUGraphInitialize (graph);
        NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Start the graph
        result = AUGraphStart (graph);
        NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Print out the graph to the console
        CAShow (graph); 
    }
}

// Set the mixer unit input volume for a specified bus
- (void) setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) newGain {
    
    /*
     This method does *not* ensure that sound loops stay in sync if the user has
     moved the volume of an input channel to zero. When a channel's input
     level goes to zero, the corresponding input render callback is no longer
     invoked. Consequently, the sample number for that channel remains constant
     while the sample number for the other channel continues to increment. As a
     workaround, the view controller Nib file specifies that the minimum input
     level is 0.01, not zero.
     
     The enableMixerInput:isOn: method in this class, however, does ensure that the
     loops stay in sync when a user disables and then reenables an input bus.
     */
    OSStatus result = AudioUnitSetParameter (
                                             _mixerUnit,
                                             kMultiChannelMixerParam_Volume,
                                             kAudioUnitScope_Input,
                                             inputBus,
                                             newGain,
                                             0
                                             );
    
    NSAssert (result == noErr, @"AudioUnitSetParameter (set mixer unit input volume) Error code: %d '%.4s'", (int) result, (const char *)&result);    
}

// Set up the audio session for this app.
- (BOOL) setupAudioSession {
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    // Specify that this object is the delegate of the audio session, so that
    //    this object's endInterruption method will be invoked when needed.
    [mySession setDelegate: self];
    
    // Assign the Playback category to the audio session. This category supports
    //    audio output with the Ring/Silent switch in the Silent position.
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayback error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting audio session category."); return NO;}
    
    // Request a desired hardware sample rate.
    self.graphSampleRate = 44100.0;    // Hertz
    
    [mySession setPreferredHardwareSampleRate: self.graphSampleRate error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting preferred hardware sample rate."); return NO;}
    
    // Activate the audio session
    [mySession setActive: YES error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error activating the audio session."); return NO;}
    
    // Obtain the actual hardware sample rate and store it for later use in the audio processing graph.
    self.graphSampleRate = [mySession currentHardwareSampleRate];
    
    return YES;
}

#pragma mark -
#pragma mark Audio Control

// Stop the audio processing graph
- (void) stopAudioProcessingGraph {
    
    OSStatus result = noErr;
	if (self.processingGraph) result = AUGraphStop(self.processingGraph);
    NSAssert (result == noErr, @"Unable to stop the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
}

// Restart the audio processing graph
- (void) restartAudioProcessingGraph {
    
    OSStatus result = noErr;
	if (self.processingGraph) result = AUGraphStart (self.processingGraph);
    NSAssert (result == noErr, @"Unable to restart the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
}

// Load a synthesizer preset file and apply it to the Sampler unit
- (OSStatus) loadSynthFromPresetURL: (NSURL *) presetURL withInstrumentID:(UInt8)InstrID {
    
	CFDataRef propertyResourceData = 0;
	Boolean status;
	SInt32 errorCode = 0;
	OSStatus result = noErr;
	
	// Read from the URL and convert into a CFData chunk
	status = CFURLCreateDataAndPropertiesFromResource (
                                                       kCFAllocatorDefault,
                                                       (__bridge CFURLRef) presetURL,
                                                       &propertyResourceData,
                                                       NULL,
                                                       NULL,
                                                       &errorCode
                                                       );
    
    NSAssert (status == YES && propertyResourceData != 0, @"Unable to create data and properties from a preset. Error code: %d '%.4s'", (int) errorCode, (const char *)&errorCode);
   	
	// Convert the data object into a property list
	CFPropertyListRef presetPropertyList = 0;
	CFPropertyListFormat dataFormat = 0;
	CFErrorRef errorRef = 0;
	presetPropertyList = CFPropertyListCreateWithData (
                                                       kCFAllocatorDefault,
                                                       propertyResourceData,
                                                       kCFPropertyListImmutable,
                                                       &dataFormat,
                                                       &errorRef
                                                       );
    
    // Set the class info property for the Sampler unit using the property list as the value.
    // Here is the direct link between AUPreset and samplerUnits.
    // Make use of this point to implement multiple musical instruments.
	if (presetPropertyList != 0) {
		switch (InstrID) {
            case Trombone:
                result = AudioUnitSetProperty(
                                              self.samplerUnit_1,
                                              kAudioUnitProperty_ClassInfo,
                                              kAudioUnitScope_Global,
                                              0,
                                              &presetPropertyList,
                                              sizeof(CFPropertyListRef)
                                              );
                break;
                
            case Loop:
                result = AudioUnitSetProperty(
                                              self.samplerUnit_2,
                                              kAudioUnitProperty_ClassInfo,
                                              kAudioUnitScope_Global,
                                              0,
                                              &presetPropertyList,
                                              sizeof(CFPropertyListRef)
                                              );
                break;
                
            case MuteElecGuitar:
                result = AudioUnitSetProperty(
                                              self.samplerUnit_3,
                                              kAudioUnitProperty_ClassInfo,
                                              kAudioUnitScope_Global,
                                              0,
                                              &presetPropertyList,
                                              sizeof(CFPropertyListRef)
                                              );
                break;
                
            case Guitar:
                result = AudioUnitSetProperty(
                                              self.samplerUnit_4,
                                              kAudioUnitProperty_ClassInfo,
                                              kAudioUnitScope_Global,
                                              0,
                                              &presetPropertyList,
                                              sizeof(CFPropertyListRef)
                                              );
                break;
                
            case Ensemble:
                result = AudioUnitSetProperty(
                                              self.samplerUnit_5,
                                              kAudioUnitProperty_ClassInfo,
                                              kAudioUnitScope_Global,
                                              0,
                                              &presetPropertyList,
                                              sizeof(CFPropertyListRef)
                                              );
                break;
                
            case Piano:
                result = AudioUnitSetProperty(
                                              self.samplerUnit_6,
                                              kAudioUnitProperty_ClassInfo,
                                              kAudioUnitScope_Global,
                                              0,
                                              &presetPropertyList,
                                              sizeof(CFPropertyListRef)
                                              );
                break;
                
            case Vibraphone:
                result = AudioUnitSetProperty(
                                              self.samplerUnit_7,
                                              kAudioUnitProperty_ClassInfo,
                                              kAudioUnitScope_Global,
                                              0,
                                              &presetPropertyList,
                                              sizeof(CFPropertyListRef)
                                              );
                break;
                
            default:
                break;
        }
		
        
		CFRelease(presetPropertyList);
	}
    
    if (errorRef) CFRelease(errorRef);
	CFRelease (propertyResourceData);
    
	return result;
}

#pragma mark -
#pragma mark Audio session delegate methods

// Respond to an audio interruption, such as a phone call or a Clock alarm.
- (void) beginInterruption {
    
    // Stop any notes that are currently playing.
    [self stopMIDI:self.currentPlayingNote];
    
    // Interruptions do not put an AUGraph object into a "stopped" state, so
    //    do that here.
    [self stopAudioProcessingGraph];
}


// Respond to the ending of an audio interruption.
- (void) endInterruptionWithFlags: (NSUInteger) flags {
    
    NSError *endInterruptionError = nil;
    [[AVAudioSession sharedInstance] setActive: YES
                                         error: &endInterruptionError];
    if (endInterruptionError != nil) {
        
        NSLog (@"Unable to reactivate the audio session.");
        return;
    }
    
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
        
        /*
         In a shipping application, check here to see if the hardware sample rate changed from
         its previous value by comparing it to graphSampleRate. If it did change, reconfigure
         the ioInputStreamFormat struct to use the new sample rate, and set the new stream
         format on the two audio units. (On the mixer, you just need to change the sample rate).
         
         Then call AUGraphUpdate on the graph before starting it.
         */
        
        [self restartAudioProcessingGraph];
    }
}

#pragma mark - Application state management

// The audio processing graph should not run when the screen is locked or when the app has
//  transitioned to the background, because there can be no user interaction in those states.
//  (Leaving the graph running with the screen locked wastes a significant amount of energy.)
//
// Responding to these UIApplication notifications allows this class to stop and restart the
//    graph as appropriate.
- (void) registerForUIApplicationNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleResigningActive:)
                               name: UIApplicationWillResignActiveNotification
                             object: [UIApplication sharedApplication]];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleBecomingActive:)
                               name: UIApplicationDidBecomeActiveNotification
                             object: [UIApplication sharedApplication]];
}


- (void) handleResigningActive: (id) notification {
    
    [self stopMIDI:self.currentPlayingNote];
    [self stopAudioProcessingGraph];
}


- (void) handleBecomingActive: (id) notification {
    
    [self restartAudioProcessingGraph];
}

@end

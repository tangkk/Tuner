//
//  Communicator.m
//  Tuner
//
//  Created by tangkk on 10/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "Communicator.h"
#import "ModeSelection.h"

#import "MIDINote.h"
#import "VirtualInstrument.h"

// Import the PGMidi functionality
#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>

@interface Communicator() <PGMidiDelegate, PGMidiSourceDelegate>

@property (readwrite) VirtualInstrument *VI;

- (void) sendMidiDataInBackground:(MIDINote *)midinote;

@end

@implementation Communicator

-(id)init {
    self = [super init];
    if (self) {
        _midi = nil;
        _VI = [[VirtualInstrument alloc] init];
        return self;
    }
    return nil;
}

- (void) dealloc {
    _midi = nil;
    _VI = nil;
}

#pragma mark IBActions

- (void) sendMidiData:(MIDINote *)midinote
{
    [self performSelectorInBackground:@selector(sendMidiDataInBackground:) withObject:midinote];
}

- (void) playMidiData:(MIDINote*)midinote
{
    if (_VI) {
        [_VI playMIDI:midinote];
    }
}

#pragma mark Shenanigans

- (void) attachToAllExistingSources
{
    for (PGMidiSource *source in _midi.sources)
    {
        [source addDelegate:self];
    }
}

- (void) setMidi:(PGMidi*)m
{
    _midi.delegate = nil;
    _midi = m;
    _midi.delegate = self;
    
    [self attachToAllExistingSources];
}


NSString *StringFromPacket(const MIDIPacket *packet)
{
    // Note - this is not an example of MIDI parsing. I'm just dumping
    // some bytes for diagnostics.
    // See comments in PGMidiSourceDelegate for an example of how to
    // interpret the MIDIPacket structure.
    return [NSString stringWithFormat:@"  %u bytes: [%02x,%02x,%02x]",
            packet->length,
            (packet->length > 0) ? packet->data[0] : 0,
            (packet->length > 1) ? packet->data[1] : 0,
            (packet->length > 2) ? packet->data[2] : 0
            ];
}

// These four methods are required by PGMidiDelegate
- (void) midi:(PGMidi*)midi sourceAdded:(PGMidiSource *)source
{
    [source addDelegate:self];
}

- (void) midi:(PGMidi*)midi sourceRemoved:(PGMidiSource *)source
{
}

- (void) midi:(PGMidi*)midi destinationAdded:(PGMidiDestination *)destination
{
}

- (void) midi:(PGMidi*)midi destinationRemoved:(PGMidiDestination *)destination
{
}

- (void) handlemidiReceived:(const MIDIPacket *)packet {
    UInt8 noteType;
    UInt8 noteNum;
    UInt8 Velocity;
    noteType = (packet->length > 0) ? packet->data[0] : 0;
    noteNum = (packet->length > 1) ? packet->data[1] : 0;
    Velocity = (packet->length >2) ? packet->data[2] : 0;
    MIDINote *Note = [[MIDINote alloc] initWithNote:noteNum duration:1 channel:kChannel_0 velocity:Velocity];
    [self playMidiData:Note];
}

// This is require by PGMidiSourceDelegate protocol. It is for MIDI packet receiving.
- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
#ifdef TEST
        NSLog(@"MIDI received:");
        NSLog(StringFromPacket(packet));
        
        // handle the packet.
        [self handlemidiReceived:packet];
#endif
#ifdef MASTER
        // handle the packet.
        [self handlemidiReceived:packet];
#endif
        
        packet = MIDIPacketNext(packet);
    }
}

- (void) sendMidiDataInBackground:(id)midinote {
    MIDINote *midiNote = midinote;
    const UInt8 note      = [midiNote note];
    const UInt8 noteOn[]  = { 0x90, note, [midiNote velocity] };
    const UInt8 noteOff[] = { 0x80, note, 0   };
        
    [_midi sendBytes:noteOn size:sizeof(noteOn)];
    [NSThread sleepForTimeInterval:1]; // changed from 0.1 so the note lasts a little longer
    [_midi sendBytes:noteOff size:sizeof(noteOff)];
    }
    //[self addString:@"\n"];
}


@end

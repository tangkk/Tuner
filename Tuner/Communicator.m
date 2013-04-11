//
//  Communicator.m
//  Tuner
//
//  Created by tangkk on 10/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "Communicator.h"

#import "MIDINote.h"
#import "NoteNumDict.h"

// Import the PGMidi functionality
#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>

@interface Communicator() <PGMidiDelegate, PGMidiSourceDelegate>

@property(readonly)NoteNumDict *Dict;
- (void) sendMidiDataInBackground:(NSNumber *)NoteNum;

@end

@implementation Communicator

-(id)init {
    self = [super init];
    if (self) {
        _Dict = [[NoteNumDict alloc] init];
        _midi = nil;
        return self;
    }
    return nil;
}

#pragma mark IBActions

- (void) sendMidiData:(MIDINote *)midinote
{
    NSString *noteName = midinote.note;
    NSNumber *NoteNum = [_Dict.Dict objectForKey:noteName];
    [self performSelectorInBackground:@selector(sendMidiDataInBackground:) withObject:NoteNum];
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

// This is require by PGMidiSourceDelegate protocol. It is for MIDI packet receiving.
- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
//        [self performSelectorOnMainThread:@selector(addString:)
//                               withObject:StringFromPacket(packet)
//                            waitUntilDone:NO];
        packet = MIDIPacketNext(packet);
    }
}

- (void) sendMidiDataInBackground:(id)NoteNum {
    const UInt8 note      = [NoteNum unsignedShortValue];
    const UInt8 noteOn[]  = { 0x90, note, 127 };
    const UInt8 noteOff[] = { 0x80, note, 0   };
        
    [_midi sendBytes:noteOn size:sizeof(noteOn)];
    [NSThread sleepForTimeInterval:0.5]; // changed from 0.1 so the note lasts a little longer
    [_midi sendBytes:noteOff size:sizeof(noteOff)];
}

@end

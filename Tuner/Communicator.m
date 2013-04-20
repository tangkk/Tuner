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
#import "NoteNumDict.h"

// Import the PGMidi functionality
#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"
#import <CoreMIDI/CoreMIDI.h>

@interface Communicator() <PGMidiDelegate, PGMidiSourceDelegate>

@property (readonly) NoteNumDict *Dict;

- (void) sendMidiDataInBackground:(MIDINote *)midinote;

@end

@implementation Communicator

-(id)init {
    self = [super init];
    if (self) {
        _midi = nil;
        if (_Dict == nil)
            _Dict = [[NoteNumDict alloc] init];
        
        return self;
    }
    return nil;
}

- (void) dealloc {
    _midi = nil;
    _Dict = nil;
}

#pragma mark IBActions

- (void) sendMidiData:(MIDINote *)midinote
{
    [self performSelectorInBackground:@selector(sendMidiDataInBackground:) withObject:midinote];
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
    return [NSString stringWithFormat:@"  %u bytes: [%02x,%02x,%02x, %02x,%02x,%02x, %02x,%02x,%02x, %02x, %02x]",
            packet->length,
            (packet->length > 0) ? packet->data[0] : 0,
            (packet->length > 1) ? packet->data[1] : 0,
            (packet->length > 2) ? packet->data[2] : 0,
            (packet->length > 3) ? packet->data[3] : 0,
            (packet->length > 4) ? packet->data[4] : 0,
            (packet->length > 5) ? packet->data[5] : 0,
            (packet->length > 6) ? packet->data[6] : 0,
            (packet->length > 7) ? packet->data[7] : 0,
            (packet->length > 8) ? packet->data[8] : 0,
            (packet->length > 9) ? packet->data[9] : 0,
            (packet->length > 10) ? packet->data[10] : 0
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
    NSLog(@"handlemidiReceived:");
#ifdef MASTER
    NSLog(@"_PlaybackDelegate:");
    [[self PlaybackDelegate] MIDIPlayback:packet];
#endif
    
#ifdef SLAVE
    NSLog(@"_AssignmentDelegate:");
    [[self AssignmentDelegate] MIDIAssignment:packet];
#endif
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
#endif
        
        [self handlemidiReceived:packet];

        
        packet = MIDIPacketNext(packet);
    }
}

- (void) sendMidiDataInBackground:(id)midinote {
    MIDINote *midiNote = midinote;
#ifdef SLAVE
    // Send normal MIDI notes
    const UInt8 note      = [midiNote note];
    const UInt8 noteOn[]  = { 0x90, note, [midiNote velocity] };
    const UInt8 noteOff[] = { 0x80, note, 0   };
        
    [_midi sendBytes:noteOn size:sizeof(noteOn)];
    [NSThread sleepForTimeInterval:1]; // changed from 0.1 so the note lasts a little longer
    [_midi sendBytes:noteOff size:sizeof(noteOff)];
#endif
    
#ifdef MASTER
    // Send SysEx Messages. Basically this is the music assignment procedure.
    UInt8 noteSysEx[11] = {0xF0, 0x7D};
    NSArray *SysEx = midiNote.SysEx;
    NSEnumerator *enumerator = [SysEx objectEnumerator];
    id object;
    
    UInt8 i = 2; // Start to assign the noteSysEx array at index 2.
    while ((object = [enumerator nextObject])) {
        NSString *noteName = object;
        NSNumber *noteNum = [_Dict.Dict objectForKey:noteName];
        noteSysEx[i] = [noteNum unsignedCharValue];
        i++;
    }
    noteSysEx[10] = 0xF7;
    [_midi sendBytes:noteSysEx size:sizeof(noteSysEx)];
#endif
}


@end

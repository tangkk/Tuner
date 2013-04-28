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
    NSLog(@"Slave Send Normal Note");
    const UInt8 channel = [midiNote channel];
    const UInt8 note      = [midiNote note];
    const UInt8 noteOn[]  = { 0x90|channel, note, [midiNote velocity] };
    const UInt8 noteOff[] = { 0x80|channel, note, 0   };
        
    [_midi sendBytes:noteOn size:sizeof(noteOn)];
    [NSThread sleepForTimeInterval:1]; // changed from 0.1 so the note lasts a little longer
    [_midi sendBytes:noteOff size:sizeof(noteOff)];
#endif
    
#ifdef MASTER
    NSArray *SysEx = midiNote.SysEx;
    UInt8 Root = midiNote.Root;
    if (SysEx.count == 8) {
        NSLog(@"Master Send Normal Assignment");
        // Send SysEx Messages. Basically this is the music assignment procedure.
        UInt8 noteSysEx[11] = {0xF0, 0x7D};
        NSEnumerator *enumerator = [SysEx objectEnumerator];
        id object;
        
        UInt8 i = 2; // Start to assign the noteSysEx array at index 2.
        while ((object = [enumerator nextObject])) {
            NSString *noteName = object;
            NSNumber *noteNum = [_Dict.Dict objectForKey:noteName];
            noteSysEx[i] = [noteNum unsignedCharValue];
            
            // Deal with the Root/Key, using C as pivot
            if (Root <= 5) {
                noteSysEx[i] += Root;
            } else {
                noteSysEx[i] += Root;
                noteSysEx[i] -= 12;
            }
            
            i++;
        }
        noteSysEx[10] = 0xF7;
        [_midi sendBytes:noteSysEx size:sizeof(noteSysEx)];
    } else if (SysEx.count == 0) {
        NSLog(@"Master shut all the players");
        // All notes off assignment
        UInt8 noteSysEx[3] = {0xF0, 0x7D, 0xF7};
        [_midi sendBytes:noteSysEx size:sizeof(noteSysEx)];
    } else if (SysEx.count == 4){
        NSLog(@"Master broadcast MIDI channel mapping");
        // Broadcast the MIDI channel mapping
        UInt8 ad1 = (UInt8) [SysEx[0] intValue];
        UInt8 ad2 = (UInt8) [SysEx[1] intValue];
        UInt8 ad3 = (UInt8) [SysEx[2] intValue];
        UInt8 ad4 = (UInt8) [SysEx[3] intValue];
        NSLog(@"add1: %d, add2: %d, add3: %d, add4: %d", ad1, ad2, ad3, ad4);
        
        // The IP address unit each should be further divided into two parts each to transfer by coreMIDI
        UInt8 ad1_1 = ad1 >> 4;
        UInt8 ad1_2 = ad1 & 0x0F;
        UInt8 ad2_1 = ad2 >> 4;
        UInt8 ad2_2 = ad2 & 0x0F;
        UInt8 ad3_1 = ad3 >> 4;
        UInt8 ad3_2 = ad3 & 0x0F;
        UInt8 ad4_1 = ad4 >> 4;
        UInt8 ad4_2 = ad4 & 0x0F;
        NSLog(@"ad1_1: %x, ad2_1: %x, ad3_1: %x, ad4_1: %x", ad1_1, ad2_1, ad3_1, ad4_1);
        NSLog(@"ad1_2: %x, ad2_2: %x, ad3_2: %x, ad4_2: %x", ad1_2, ad2_2, ad3_2, ad4_2);
        NSLog(@"Root: %d", Root);
        
        const UInt8 noteSysEx[12] = {0xF0, 0x7D, ad1_1, ad1_2, ad2_1, ad2_2, ad3_1, ad3_2, ad4_1, ad4_2, Root, 0xF7};
        [_midi sendBytes:noteSysEx size:sizeof(noteSysEx)];
    } else {
        NSLog(@"OOps! Something went wrong!");
    }

#endif
}


@end

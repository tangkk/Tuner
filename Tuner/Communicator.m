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

@interface Communicator() <PGMidiDelegate, PGMidiSourceDelegate, NSNetServiceBrowserDelegate>

@property (readwrite) VirtualInstrument *VI;

- (void) sendMidiDataInBackground:(MIDINote *)midinote;

@end

@implementation Communicator

-(id)init {
    self = [super init];
    if (self) {
        _midi = nil;
        _VI = [[VirtualInstrument alloc] init];
        [self configureNetworkSessionAndServiceBrowser];
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

// This is require by PGMidiSourceDelegate protocol. It is for MIDI packet receiving.
- (void) midiSource:(PGMidiSource*)midi midiReceived:(const MIDIPacketList *)packetList
{
    const MIDIPacket *packet = &packetList->packet[0];
    for (int i = 0; i < packetList->numPackets; ++i)
    {
        NSLog(@"MIDI received:");
        NSLog(StringFromPacket(packet));
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

- (void) configureNetworkSessionAndServiceBrowser {
    // configure network session
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    session.enabled = YES;
    session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
    // configure service browser
    self.services = [[NSMutableArray alloc] init];
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
    // starting scanning for services (won't stop until stop() is called)
    [self.serviceBrowser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@"local."];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // add connection here!
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    MIDINetworkHost *host = [MIDINetworkHost hostWithName:[service name] netService:service];
    MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
    // note: check to exclude itself - WARNING: will have problem if network names happen to be the same
    if (![service.name isEqualToString:session.networkName] && [session addConnection:connection]) {
        //[self addString:[NSString stringWithFormat:@"Connected to device: %@", [service name]]];
        [self.services addObject:service];
    }
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    MIDINetworkHost *host = [MIDINetworkHost hostWithName:[service name] netService:service];
    MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
    if ([session removeConnection:connection]) {
        //[self addString:[NSString stringWithFormat:@"Removed device: %@", [service name]]];
    }
    [self.services removeObject:service];
}

- (void) listConnectedDevices {
    NSSet *connections = [MIDINetworkSession defaultSession].connections;
    //[self addString:[NSString stringWithFormat:@"List of all %u connected devices:", [connections count]]];
    for (MIDINetworkConnection *conn in connections) {
        //[self addString: [NSString stringWithFormat:@"\"%@\" ", conn.host.netServiceName]];
    }
    //[self addString:@"\n"];
}


@end

//
//  TunerViewController.m
//  Tuner
//
//  Created by tangkk on 12/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "TunerViewController.h"
#import "ModeSelection.h"

#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"

#import "MIDINote.h"
#import "NoteNumDict.h"
#import "Communicator.h"

@interface TunerViewController ()

@property (readwrite) Communicator *CMU;
@property (readonly) NoteNumDict *Dict;

@end

@implementation TunerViewController

MIDINote *M1, *M2, *M3, *M4, *M5, *M6;
NSNumber *N1, *N2, *N3, *N4, *N5, *N6;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    _CMU = [[Communicator alloc] init];
    _Dict = [[NoteNumDict alloc] init];
    
    N1 = [_Dict.Dict objectForKey:self.B1.titleLabel.text];
    N2 = [_Dict.Dict objectForKey:self.B2.titleLabel.text];
    N3 = [_Dict.Dict objectForKey:self.B3.titleLabel.text];
    N4 = [_Dict.Dict objectForKey:self.B4.titleLabel.text];
    N5 = [_Dict.Dict objectForKey:self.B5.titleLabel.text];
    N6 = [_Dict.Dict objectForKey:self.B6.titleLabel.text];
    
    M1 = [[MIDINote alloc] initWithNote:[N1 unsignedShortValue] duration:1 channel:kChannel_0 velocity:100];
    M2 = [[MIDINote alloc] initWithNote:[N2 unsignedShortValue] duration:1 channel:kChannel_0 velocity:100];
    M3 = [[MIDINote alloc] initWithNote:[N3 unsignedShortValue] duration:1 channel:kChannel_0 velocity:100];
    M4 = [[MIDINote alloc] initWithNote:[N4 unsignedShortValue] duration:1 channel:kChannel_0 velocity:100];
    M5 = [[MIDINote alloc] initWithNote:[N5 unsignedShortValue] duration:1 channel:kChannel_0 velocity:100];
    M6 = [[MIDINote alloc] initWithNote:[N6 unsignedShortValue] duration:1 channel:kChannel_0 velocity:100];
    
    // If iOS has the feature, initialize coreMIDI with a networkSession
    // note that this PGMidi object is hidden from outside
    IF_IOS_HAS_COREMIDI
    (
     // We only create a MidiInput object on iOS versions that support CoreMIDI
     _CMU.midi = [[PGMidi alloc] init];
     _CMU.midi.networkEnabled = YES;
     )
    [self configureNetworkSessionAndServiceBrowser];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    // Nil all the objects
    _CMU = nil;
    
    M1 = nil;
    M2 = nil;
    M3 = nil;
    M4 = nil;
    M5 = nil;
    M6 = nil;
    
    [self setB1:nil];
    [self setB2:nil];
    [self setB3:nil];
    [self setB4:nil];
    [self setB5:nil];
    [self setB6:nil];
    [super viewDidUnload];
}

- (IBAction)B1:(id)sender {
#ifdef TEST
    [_CMU playMidiData:M1];
    [_CMU sendMidiData:M1];
#endif
    
#ifdef SLAVE
    [_CMU sendMidiData:M1];
#endif
}

- (IBAction)B2:(id)sender {
#ifdef TEST
    [_CMU playMidiData:M2];
    [_CMU sendMidiData:M2];
#endif
    
#ifdef SLAVE
    [_CMU sendMidiData:M2];
#endif
}

- (IBAction)B3:(id)sender {
#ifdef TEST
    [_CMU playMidiData:M3];
    [_CMU sendMidiData:M3];
#endif
    
#ifdef SLAVE
    [_CMU sendMidiData:M3];
#endif
}

- (IBAction)B4:(id)sender {
#ifdef TEST
    [_CMU playMidiData:M4];
    [_CMU sendMidiData:M4];
#endif
    
#ifdef SLAVE
    [_CMU sendMidiData:M4];
#endif
}

- (IBAction)B5:(id)sender {
#ifdef TEST
    [_CMU playMidiData:M5];
    [_CMU sendMidiData:M5];
#endif
    
#ifdef SLAVE
    [_CMU sendMidiData:M5];
#endif
}

- (IBAction)B6:(id)sender {
#ifdef TEST
    [_CMU playMidiData:M6];
    [_CMU sendMidiData:M6];
#endif
#ifdef MASTER
    
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
#endif

#ifdef SLAVE
    [_CMU sendMidiData:M6];
#endif
}

@end

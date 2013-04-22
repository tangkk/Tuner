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
#import "AssignmentTable.h"
#import "VirtualInstrument.h"

@interface TunerViewController ()
@property (readwrite) Communicator *CMU;
@property (readonly) NoteNumDict *Dict;

#ifdef MASTER
    // Since the _Key field can be set, readwrite thus.
    @property (readonly) AssignmentTable *AST;
    @property (readonly) VirtualInstrument *VI;
#endif

#ifdef SLAVE
    @property (assign) BOOL SlaveEnable;
#endif

@end

@implementation TunerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (_CMU == nil)
        _CMU = [[Communicator alloc] init];
    if (_Dict == nil)
        _Dict = [[NoteNumDict alloc] init];
    
    
    // If iOS has the feature, initialize coreMIDI with a networkSession
    // note that this PGMidi object is hidden from outside
    IF_IOS_HAS_COREMIDI
    (
     // We only create a MidiInput object on iOS versions that support CoreMIDI
        if (_CMU.midi == nil) {
            _CMU.midi = [[PGMidi alloc] init];
            _CMU.midi.networkEnabled = YES;
        }
     )
    
#ifdef SLAVE
    _M1 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:Root_C];
    _M2 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:Root_C];
    _M3 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:Root_C];
    _M4 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:Root_C];
    _M5 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:Root_C];
    _M6 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:Root_C];
    _M7 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:Root_C];
    _M8 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:Root_C];
    _SlaveEnable = false;
    [_CMU setAssignmentDelegate:self];
#endif
    
#ifdef MASTER
    if (_VI == nil) {
        _VI = [[VirtualInstrument alloc] init];
        
        // FIXME: Should let master's UI to set instrument
        [_VI setInstrument:@"Guitar"];
    }
    if (_AST == nil)
        _AST = [[AssignmentTable alloc] init];
    if (_AST) {
        // Here the MIDI Note object contains a series of SysEx notes derived from the Assignment Table
        _M1 = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                       SysEx:[_AST.MusicAssignment objectForKey:@"Ionian_1"] Root:Root_C];
        _M2 = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                       SysEx:[_AST.MusicAssignment objectForKey:@"Ionian_2"] Root:Root_D];
        _M3 = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                       SysEx:[_AST.MusicAssignment objectForKey:@"Pentatonic_1"] Root:Root_E];
        _M4 = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                       SysEx:[_AST.MusicAssignment objectForKey:@"Pentatonic_2"] Root:Root_F];
        _M5 = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                       SysEx:[_AST.MusicAssignment objectForKey:@"Dorian_1"] Root:Root_G];
        _M6 = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                       SysEx:[_AST.MusicAssignment objectForKey:@"Dorian_2"] Root:Root_A];
    }
    [_CMU setPlaybackDelegate:self];
    [self configureNetworkSessionAndServiceBrowser];
#endif

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    // Nil all the objects
    _CMU = nil;
    
#ifdef SLAVE
    _M1 = nil;
    _M2 = nil;
    _M3 = nil;
    _M4 = nil;
    _M5 = nil;
    _M6 = nil;
    _M7 = nil;
    _M8 = nil;
    _SlaveEnable = false;
#endif
    
#ifdef MASTER
    _AST = nil;
    _VI = nil;
#endif
    
    [self setB1:nil];
    [self setB2:nil];
    [self setB3:nil];
    [self setB4:nil];
    [self setB5:nil];
    [self setB6:nil];
    [super viewDidUnload];
}

- (IBAction)B1:(id)sender {
    
#ifdef SLAVE
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M1];
    }
#endif
    
#ifdef MASTER
    [_CMU sendMidiData:_M1];
#endif
}

- (IBAction)B2:(id)sender {
    
#ifdef SLAVE
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M2];
    }
#endif
    
#ifdef MASTER
    [_CMU sendMidiData:_M2];
#endif
}

- (IBAction)B3:(id)sender {

#ifdef SLAVE
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M3];
    }
#endif
    
#ifdef MASTER
    [_CMU sendMidiData:_M3];
#endif
}

- (IBAction)B4:(id)sender {

#ifdef SLAVE
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M4];
    }
#endif
    
#ifdef MASTER
    [_CMU sendMidiData:_M4];
#endif
}

- (IBAction)B5:(id)sender {

#ifdef SLAVE
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M5];
    }
#endif
    
#ifdef MASTER
    [_CMU sendMidiData:_M5];
#endif
}

- (IBAction)B6:(id)sender {

#ifdef SLAVE
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M6];
    }
#endif
    
#ifdef MASTER
    [_CMU sendMidiData:_M6];
#endif
}

#ifdef MASTER
- (void) MIDIPlayback: (const MIDIPacket *)packet {
    // If not in slave mode, the packet is MIDI performance
    // Plays the MIDI note then.
    NSLog(@"handle midiReceived in Master Mode");
    UInt8 noteType;
    UInt8 noteNum;
    UInt8 Velocity;
    noteType = (packet->length > 0) ? packet->data[0] : 0;
    noteNum = (packet->length > 1) ? packet->data[1] : 0;
    Velocity = (packet->length >2) ? packet->data[2] : 0;
    MIDINote *Note = [[MIDINote alloc] initWithNote:noteNum duration:1 channel:kChannel_0 velocity:Velocity SysEx:0 Root:Root_C];
    
    // Play the note with Virtual Instrument
    if (_VI) {
        NSLog(@"PlayMIDI:Note");
        [_VI playMIDI:Note];
    }
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
#endif

#ifdef SLAVE
- (void) MIDIAssignment: (const MIDIPacket *)packet {
    // If in slave mode, handle sysEx messages which is the assignment of notes from the master to players
    // The packet should contain 11 datas, where data 2-9 is note assignments, data 1 is 0x7D which is the
    // manufacturer ID for educational use, data 0 is 0xF0, data 10 is 0xF7
    NSLog(@"handle midiReceived in Slave Mode");
    NSMutableArray *NewAssignment = [NSMutableArray arrayWithCapacity:8];
    if (packet->length == 11) {
        if (packet->data[0] == 0xF0 && packet->data[10]==0xF7 && packet->data[1]==0x7D) {
            NSLog(@"deals with assignment");
            // deals with the assignment here
            for (int i = 2; i < 10; i++) {
                UInt8 AssignNum = packet->data[i];
                NSNumber *AssignNSNum = [NSNumber numberWithUnsignedChar:AssignNum];
                NSArray *noteNameArr = [_Dict.Dict allKeysForObject:AssignNSNum];
                NSString *noteName = [noteNameArr objectAtIndex:0];
                if (noteName) {
                    NSLog(@"The noteName %@", noteName);
                    [NewAssignment addObject:noteName];
                }
            }
        }
    }
    
    // The new assignment will change the text label of the buttons
#ifdef TEST
    NSLog(@"NewAssignment objectAtIndex:0: %@", [NewAssignment objectAtIndex:0]);
    NSLog(@"NewAssignment objectAtIndex:1: %@", [NewAssignment objectAtIndex:1]);
    NSLog(@"NewAssignment objectAtIndex:2: %@", [NewAssignment objectAtIndex:2]);
    NSLog(@"NewAssignment objectAtIndex:3: %@", [NewAssignment objectAtIndex:3]);
#endif
    
    // FIXME: The Button's label would only update by tapping once. Don't know why.
    [_B1 setTitle:[NewAssignment objectAtIndex:0] forState:UIControlStateNormal];
    [_B2 setTitle:[NewAssignment objectAtIndex:1] forState:UIControlStateNormal];
    [_B3 setTitle:[NewAssignment objectAtIndex:2] forState:UIControlStateNormal];
    [_B4 setTitle:[NewAssignment objectAtIndex:3] forState:UIControlStateNormal];
    [_B5 setTitle:[NewAssignment objectAtIndex:4] forState:UIControlStateNormal];
    [_B6 setTitle:[NewAssignment objectAtIndex:5] forState:UIControlStateNormal];
    
    NSNumber  *N1 = [_Dict.Dict objectForKey:self.B1.titleLabel.text];
    NSNumber  *N2 = [_Dict.Dict objectForKey:self.B2.titleLabel.text];
    NSNumber  *N3 = [_Dict.Dict objectForKey:self.B3.titleLabel.text];
    NSNumber  *N4 = [_Dict.Dict objectForKey:self.B4.titleLabel.text];
    NSNumber  *N5 = [_Dict.Dict objectForKey:self.B5.titleLabel.text];
    NSNumber  *N6 = [_Dict.Dict objectForKey:self.B6.titleLabel.text];
    
    [_M1 setNote:[N1 unsignedShortValue]];
    [_M2 setNote:[N2 unsignedShortValue]];
    [_M3 setNote:[N3 unsignedShortValue]];
    [_M4 setNote:[N4 unsignedShortValue]];
    [_M5 setNote:[N5 unsignedShortValue]];
    [_M6 setNote:[N6 unsignedShortValue]];
    
    _SlaveEnable = true;
}
#endif


@end

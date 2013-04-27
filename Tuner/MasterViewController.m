//
//  MasterViewController.m
//  Tuner
//
//  Created by tangkk on 25/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "MasterViewController.h"

#import "ModeSelection.h"

#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"

#import "MIDINote.h"
#import "NoteNumDict.h"
#import "Communicator.h"
#import "AssignmentTable.h"
#import "VirtualInstrument.h"

@interface MasterViewController ()

@property (readwrite) Communicator *CMU;
@property (readonly) NoteNumDict *Dict;

@property (readonly) AssignmentTable *AST;
@property (readonly) VirtualInstrument *VI;
@property (readonly) MIDINote *LOFF;

@property (readonly) UInt8 CurrentGroove;
@property (copy) NSString *ScaleName;
@property (copy) NSString *GrooveName;
@property (readwrite) UInt8 Key;
@property (copy) NSString *KeyName;
@property (copy) NSString *Pattern;

@property (readwrite) BOOL AssignmentUpdatable;

// Assignment Note
@property (readwrite) MIDINote *Assignment;
// Groove Note
@property (readwrite) MIDINote *GROOVE;

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureNetworkSessionAndServiceBrowser];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    if (_VI == nil) {
        _VI = [[VirtualInstrument alloc] init];
        
        // FIXME: Should let master's UI to set instrument for different musical instrument
        [_VI setInstrument:@"Trombone" withInstrumentID:Trombone]; //This is the groove instrument
        [_VI setInstrument:@"Loop" withInstrumentID:Loop];
        [_VI setInstrument:@"MuteElecGuitar" withInstrumentID:MuteElecGuitar];
        [_VI setInstrument:@"Guitar" withInstrumentID:Guitar];
        [_VI setInstrument:@"Ensemble" withInstrumentID:Ensemble];
        [_VI setInstrument:@"Piano" withInstrumentID:Piano];
        [_VI setInstrument:@"Vibraphone" withInstrumentID:Vibraphone];
    }
    if (_AST == nil)
        _AST = [[AssignmentTable alloc] init];
    if (_AST) {
        // Here the MIDI Note object contains a series of SysEx notes derived from the Assignment Table
        _Assignment = [[MIDINote alloc] initWithNote:0 duration:0 channel:kChannel_0 velocity:0
                                       SysEx:[_AST.MusicAssignment objectForKey:@"Ionian_1"] Root:Root_C];
        _ScaleName = @"Ionian_1";
        _Pattern = @"_1";
        _KeyName = @"C";
        _Key = Root_C;
        //Loop nodes
        _GROOVE = [[MIDINote alloc] initWithNote:Ballad3 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
        _CurrentGroove = Ballad3;
        _GrooveName = @"Ballad3";
        _LOFF = [[MIDINote alloc] initWithNote:Ballad3 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOff];
    }
    [_CMU setPlaybackDelegate:self];
    
    _AssignmentLabel.text = [[NSString alloc] initWithFormat:@"Groove: %@\nKey: %@\nScale: %@",
                             _GrooveName, _KeyName, _ScaleName];
    _AssignmentUpdatable = false;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    // Nil all the objects
    _CMU = nil;
    _Dict = nil;
    _Assignment = nil;
    
    _AST = nil;
    _VI = nil;
    _GROOVE = nil;
    _LOFF = nil;
    _CurrentGroove = 0;
    _ScaleName = nil;
    _GrooveName = nil;
    _KeyName = nil;
    _Key = 0;
    _Pattern = nil;
    _AssignmentUpdatable = false;
    
    [self setPlayer1:nil];
    [self setPlayer2:nil];
    [self setPlayer3:nil];
    [self setPlayer4:nil];
    [self setPlayer5:nil];
    [self setPlayer6:nil];
    [self setGroove1:nil];
    [self setGroove2:nil];
    [self setGroove3:nil];
    [self setGroove4:nil];
    [self setGroove5:nil];
    [self setGroove6:nil];
    [self setStart:nil];
    [self setVolume:nil];
    [self setPan:nil];
    [self setAssignmentLabel:nil];
    [self setDebug:nil];
    [super viewDidUnload];
}

- (void) updateAssignmentLabel {
    _AssignmentLabel.text = [[NSString alloc] initWithFormat:@"Groove: %@\nKey: %@\nScale: %@",
                             _GrooveName, _KeyName, _ScaleName];
}

- (void) updateAssignment {
    [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:_ScaleName]];
    [_Assignment setRoot:_Key];
    [_CMU sendMidiData:_Assignment];
}

// Players
- (IBAction)Player1:(id)sender {
}

- (IBAction)Player2:(id)sender {
}

- (IBAction)Player3:(id)sender {
}

- (IBAction)Player4:(id)sender {
}

- (IBAction)Player5:(id)sender {
}

- (IBAction)Player6:(id)sender {
}

// Grooves
- (IBAction)Groove1:(id)sender {
    [_GROOVE setNote:Ballad3];
    _GrooveName = @"Ballad3";
    [self updateAssignmentLabel];
}

- (IBAction)Groove2:(id)sender {
    [_GROOVE setNote:Ballad4];
    _GrooveName = @"Ballad4";
    [self updateAssignmentLabel];
}

- (IBAction)Groove3:(id)sender {
    [_GROOVE setNote:Funky1];
    _GrooveName = @"Funky1";
    [self updateAssignmentLabel];
}

- (IBAction)Groove4:(id)sender {
    [_GROOVE setNote:Funky2];
    _GrooveName = @"Funky2";
    [self updateAssignmentLabel];
}

- (IBAction)Groove5:(id)sender {
    [_GROOVE setNote:Rock2];
    _GrooveName = @"Rock2";
    [self updateAssignmentLabel];
}

- (IBAction)Groove6:(id)sender {
    [_GROOVE setNote:Rock3];
    _GrooveName = @"Rock3";
    [self updateAssignmentLabel];
}

// *****************Starts********************//
- (IBAction)Start:(id)sender {
    // Send out the assignments
    [_Assignment setSysEx:[_AST.MusicAssignment objectForKey:_ScaleName]];
    [_Assignment setRoot:_Key];
    [_CMU sendMidiData:_Assignment];
    
    [_LOFF setNote:_CurrentGroove];
    if (_VI) {
        [_VI playMIDI:_LOFF];
        [_VI playMIDI:_GROOVE];
    }
    _CurrentGroove = [_GROOVE note];
    
    _AssignmentUpdatable = true;
}

- (IBAction)Stop:(id)sender {
    [_Assignment setSysEx:0];
    [_CMU sendMidiData:_Assignment];
    
    [_LOFF setNote:_CurrentGroove];
    if (_VI)
        [_VI playMIDI:_LOFF];
    
    _AssignmentUpdatable = false;
}

- (IBAction)StopAccepting:(id)sender {
    [self IdentifyConnectedDevices];
}

// ******************************************//

// Scales
- (IBAction)Ionian:(id)sender {
    _ScaleName = [[NSString alloc] initWithFormat:@"Ionian%@", _Pattern];
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)Dorian:(id)sender {
    _ScaleName = [[NSString alloc] initWithFormat:@"Dorian%@", _Pattern];
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)Phrygian:(id)sender {
    _ScaleName = [[NSString alloc] initWithFormat:@"Phrygian%@", _Pattern];
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)Lydian:(id)sender {
    _ScaleName = [[NSString alloc] initWithFormat:@"Lydian%@", _Pattern];
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)MixoLyd:(id)sender {
    _ScaleName = [[NSString alloc] initWithFormat:@"Mixolydian%@", _Pattern];
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)Aeolian:(id)sender {
    _ScaleName = [[NSString alloc] initWithFormat:@"Aeolian%@", _Pattern];
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)Pentatonic:(id)sender {
    _ScaleName = [[NSString alloc] initWithFormat:@"Pentatonic%@", _Pattern];
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)Blues:(id)sender {
}

- (IBAction)Harmonics:(id)sender {
}

- (IBAction)Jazz:(id)sender {
}

- (IBAction)Arabic:(id)sender {
}

// Scale Part
- (IBAction)Pat1:(id)sender {
    _Pattern = @"_1";
}

- (IBAction)Pat2:(id)sender {
    _Pattern = @"_2";
}

- (IBAction)Pat3:(id)sender {
}

// Key
- (IBAction)C:(id)sender {
    [_Assignment setRoot:Root_C];
    _KeyName = @"C";
    _Key = Root_C;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)CC:(id)sender {
    [_Assignment setRoot:Root_CC];
    _KeyName = @"C#";
    _Key = Root_CC;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)D:(id)sender {
    [_Assignment setRoot:Root_D];
    _KeyName = @"D";
    _Key = Root_D;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)DD:(id)sender {
    [_Assignment setRoot:Root_DD];
    _KeyName = @"D#";
    _Key = Root_DD;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)E:(id)sender {
    [_Assignment setRoot:Root_E];
    _KeyName = @"E";
    _Key = Root_E;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)F:(id)sender {
    [_Assignment setRoot:Root_F];
    _KeyName = @"F";
    _Key = Root_F;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)FF:(id)sender {
    [_Assignment setRoot:Root_FF];
    _KeyName = @"F#";
    _Key = Root_FF;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)G:(id)sender {
    [_Assignment setRoot:Root_G];
    _KeyName = @"G";
    _Key = Root_G;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)GG:(id)sender {
    [_Assignment setRoot:Root_GG];
    _KeyName = @"G#";
    _Key = Root_GG;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)A:(id)sender {
    [_Assignment setRoot:Root_A];
    _KeyName = @"A";
    _Key = Root_A;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)AA:(id)sender {
    [_Assignment setRoot:Root_AA];
    _KeyName = @"A#";
    _Key = Root_AA;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (IBAction)B:(id)sender {
    [_Assignment setRoot:Root_B];
    _KeyName = @"B";
    _Key = Root_B;
    [self updateAssignmentLabel];
    if (_AssignmentUpdatable) {
        [self updateAssignment];
    }
}

- (void) MIDIPlayback: (const MIDIPacket *)packet {
    // This is a MIDI performance note
    NSLog(@"handle midiReceived in Master Mode");
    UInt8 noteTypeAndChannel;
    UInt8 noteNum;
    UInt8 Velocity;
    noteTypeAndChannel = (packet->length > 0) ? packet->data[0] : 0;
    noteNum = (packet->length > 1) ? packet->data[1] : 0;
    Velocity = (packet->length >2) ? packet->data[2] : 0;
    
    UInt8 noteType, noteChannel;
    noteType = noteTypeAndChannel & 0xF0;
    noteChannel = noteTypeAndChannel & 0x0F;
    NSLog(@"noteType: %x, noteChannel: %x", noteType, noteChannel);
    
    
    MIDINote *Note = [[MIDINote alloc] initWithNote:noteNum duration:1 channel:noteChannel velocity:Velocity SysEx:0 Root:noteType];
    
    // Play the note with Virtual Instrument according to the different player name.
    // When the player ID is available, the following commented function is used instead
    if (noteChannel <= 8 && _VI) {
            [_VI playMIDI:Note];
    }
}

- (void) configureNetworkSessionAndServiceBrowser {
    // configure network session
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;

    // configure service browser
    self.services = [[NSMutableArray alloc] init];
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
    // starting scanning for services (won't stop until stop() is called)
    [self.serviceBrowser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@"local."];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    [self.services addObject:service];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    MIDINetworkHost *host = [MIDINetworkHost hostWithName:[service name] netService:service];
    MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
    [self.services removeObject:service];
    [session removeConnection:connection]; // remove connection automatically no matter what
}

- (void) IdentifyConnectedDevices {
    for (NSNetService *service in self.services) {
        NSLog(@"name: %@", service.name);
        NSString * DebugMsg = [[NSString alloc] initWithFormat:@"service name: %@", service.name];
        _Debug.text = DebugMsg;
    }
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    NSLog(@"Connected to %u devices:", [session.connections count]);
    
    // Assign each connected devices a unique ID (starting from 1)
    UInt8 _ID = 1;
    for (MIDINetworkConnection *conn in session.connections) {
        NSString *name = conn.host.name;
        NSString *IP = conn.host.address;
        NSLog(@"name: %@", name);
        NSLog(@"address:%@", IP);
        NSNumber *ID = [NSNumber numberWithUnsignedChar:_ID];
        NSString * DebugMsg = [[NSString alloc] initWithFormat:@"name: %@, address: %@", name, IP];
        _Debug.text = DebugMsg;

        // Broadcast the Arr(as SysEx) and the ID(as Root) to let the corresponding player know its ID so as to specify its unique MIDI channel
        // This is how master can differentiate players.
        if (IP) {
            [_Assignment setSysEx:[IP componentsSeparatedByString:@"."]];
            [_Assignment setRoot:[ID unsignedCharValue]];
            [_CMU sendMidiData:_Assignment];
        }
        _ID ++;
    }
}

- (void)ScanPlayers{
    //[self addString:@"Start accepting connections...\n"];
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
}

- (void)StopScanning{
    //[self addString:@"Stop accepting connections...\n"];
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    session.connectionPolicy = MIDINetworkConnectionPolicy_NoOne;
}


@end

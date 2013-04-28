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
#import "VirtualInstrument.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

@interface TunerViewController ()
@property (readwrite) Communicator *CMU;
@property (readonly) NoteNumDict *Dict;
@property (assign) BOOL SlaveEnable;

@property (readwrite) UInt8 PlayerID;

@end

@implementation TunerViewController

- (void)viewWillAppear:(BOOL)animated {
    [self configureNetworkSessionAndServiceBrowser];
}

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
    
    _M1 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
    _M2 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
    _M3 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
    _M4 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
    _M5 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
    _M6 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
    _M7 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
    _M8 = [[MIDINote alloc] initWithNote:48 duration:1 channel:kChannel_0 velocity:75 SysEx:0 Root:kMIDINoteOn];
    _SlaveEnable = false;
    [_CMU setAssignmentDelegate:self];
    
    _PlayerID = 0x0F;

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
    _M1 = nil;
    _M2 = nil;
    _M3 = nil;
    _M4 = nil;
    _M5 = nil;
    _M6 = nil;
    _M7 = nil;
    _M8 = nil;
    _SlaveEnable = false;
    _PlayerID = 0x0F;
    
    [self setB1:nil];
    [self setB2:nil];
    [self setB3:nil];
    [self setB4:nil];
    [self setB5:nil];
    [self setB6:nil];
    [self setDebugMsg:nil];
    [super viewDidUnload];
}

- (IBAction)B1:(id)sender {
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M1];
    } else {
        [self startScanning];
    }
}

- (IBAction)B2:(id)sender {
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M2];
    } else {
        [self connectToEveryone];
    }
}

- (IBAction)B3:(id)sender {
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M3];
    } else {
        [self listConnectedDevices];
    }
}

- (IBAction)B4:(id)sender {
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M4];
    } else {
        [self disconnectFromMaster];
    }
}

- (IBAction)B5:(id)sender {
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M5];
    }
}

- (IBAction)B6:(id)sender {
    if (_SlaveEnable) {
        [_CMU sendMidiData:_M6];
    }
}

- (void) MIDIAssignment: (const MIDIPacket *)packet {
    // If in slave mode, handle sysEx messages which is the assignment of notes from the master to players
    // The packet should contain 11 datas, where data 2-9 is note assignments, data 1 is 0x7D which is the
    // manufacturer ID for educational use, data 0 is 0xF0, data 10 is 0xF7
    NSLog(@"handle midiReceived in Slave Mode");
    NSString*DebugMsg = [[NSString alloc] initWithFormat:@"handle midiReceived in Slave Mode"];
    _DebugMsg.text = DebugMsg;
    NSMutableArray *NewAssignment = [NSMutableArray arrayWithCapacity:8];
    if (packet->length == 11) {
        NSLog(@"deals with assignment");
        NSString*DebugMsg = [[NSString alloc] initWithFormat:@"deals with assignment"];
        _DebugMsg.text = DebugMsg;
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
    } else  if (packet->length == 3) {
        NSLog(@"deals with uuuuuuuunassignment");
        NSString*DebugMsg = [[NSString alloc] initWithFormat:@"deals with uuuuuuuunassignment"];
        _DebugMsg.text = DebugMsg;
        [_B1 setTitle:@"Scan" forState:UIControlStateNormal];
        [_B2 setTitle:@"Connect" forState:UIControlStateNormal];
        [_B3 setTitle:@"List" forState:UIControlStateNormal];
        [_B4 setTitle:@"Disconnect" forState:UIControlStateNormal];
        
        [_M1 setNote:0];
        [_M2 setNote:0];
        [_M3 setNote:0];
        [_M4 setNote:0];
        [_M5 setNote:0];
        [_M6 setNote:0];
        
        _SlaveEnable = false;
        return;
        
    } else if (packet->length == 12){
        NSLog(@"deas with MIDI channel mapping broadcast");
        NSString*DebugMsg = [[NSString alloc] initWithFormat:@"deas with MIDI channel mapping broadcast"];
        _DebugMsg.text = DebugMsg;
        // deals with MIDI channel mapping broadcasting
        UInt8 add1 = (packet->data[2]) << 4 | packet->data[3];
        UInt8 add2 = (packet->data[4]) << 4 | packet->data[5];
        UInt8 add3 = (packet->data[6]) << 4 | packet->data[7];
        UInt8 add4 = (packet->data[8]) << 4 | packet->data[9];
        NSLog(@"add1:%d, add2:%d, add3:%d, add4:%d", add1, add2, add3, add4);
        NSString*ReceiveIP = [[NSString alloc] initWithFormat:@"add1:%d, add2:%d, add3:%d, add4:%d", add1, add2, add3, add4];
        _DebugMsg.text = ReceiveIP;
        
        NSString *OwnIP = [self getIPAddress];
        
        NSArray *Arr;
        Arr = [OwnIP componentsSeparatedByString:@"."];
        int ad1 = [Arr[0] intValue];
        int ad2 = [Arr[1] intValue];
        int ad3 = [Arr[2] intValue];
        int ad4 = [Arr[3] intValue];
        
        if (add1 == (UInt8)ad1 && add2 == (UInt8)ad2 && add3 == (UInt8)ad3 && add4 == (UInt8)ad4) {
            _PlayerID = packet->data[10];
            NSLog(@"Player ID is: %d", _PlayerID);
            NSString*PlayerID = [[NSString alloc] initWithFormat:@"Player ID is: %d", _PlayerID];
            _DebugMsg.text = PlayerID;
        }
        
        _SlaveEnable = false;
        return;
        
    } else {
        NSLog(@"Oops! Something went wrong!");
        NSString*DebugMsg = [[NSString alloc] initWithFormat:@"Oops! Something went wrong!"];
        _DebugMsg.text = DebugMsg;
        _SlaveEnable = false;
        return;
    }
    
    // FIXME: The Button's label would only update after tapping once. Don't know why.
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
    
    [_M1 setChannel:_PlayerID];
    [_M2 setChannel:_PlayerID];
    [_M3 setChannel:_PlayerID];
    [_M4 setChannel:_PlayerID];
    [_M5 setChannel:_PlayerID];
    [_M6 setChannel:_PlayerID];
    
    _SlaveEnable = true;
}

- (void) configureNetworkSessionAndServiceBrowser {
    // configure network session
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];

    session.connectionPolicy = MIDINetworkConnectionPolicy_NoOne;
    // configure service browser
    self.services = [[NSMutableArray alloc] init];
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [self.serviceBrowser setDelegate:self];
    // starting scanning for services (won't stop until stop() is called)
    [self.serviceBrowser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@"local."];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // add connection here!
    [self.services addObject:service];
}

- (void) netServiceBrowser:(NSNetServiceBrowser*)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    MIDINetworkHost *host = [MIDINetworkHost hostWithName:[service name] netService:service];
    MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
    [self.services removeObject:service];
    [session removeConnection:connection]; // remove connection automatically no matter what
}

- (void) listConnectedDevices {
    // Probably only one master
    NSLog(@"List of all %u devices on the network:", [self.services count]);
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    NSLog(@"Connected to %u devices:", [session.connections count]);
    for (MIDINetworkConnection *conn in session.connections) {
        NSLog(@"MIDINetworkConnection master name: %@", conn.host.name);
        NSLog(@"MIDINetworkConnection master address: %@", conn.host.address);
        NSString*DebugMsg = [[NSString alloc] initWithFormat:@"Master: %@", conn.host.name];
        _DebugMsg.text = DebugMsg;
    }
    
    NSString *OwnIP = [self getIPAddress];
    NSLog(@"OwnIP: %@", OwnIP);
    
}

- (void) connectToEveryone {
    NSLog(@"Trying to connect to everyone (hopefully only the Master)...");
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    for (NSNetService *service in self.services) {
        MIDINetworkHost *host = [MIDINetworkHost hostWithName:[service name] netService:service];
        MIDINetworkConnection *connection = [MIDINetworkConnection connectionWithHost:host];
        [session addConnection:connection];
    }
}

- (void) disconnectFromMaster {
    NSLog(@"Trying to disconnect...\n");
    MIDINetworkSession *session = [MIDINetworkSession defaultSession];
    // create temp array to avoid remove-on-the-fly bugs
    NSMutableArray *connections = [[NSMutableArray alloc] init];
    for (MIDINetworkConnection *conn in session.connections) {
        [connections addObject:conn];
    }
    for (MIDINetworkConnection *conn in connections) {
        [session removeConnection:conn];
    }
}

- (void) startScanning {
    NSLog(@"Resume scanning for devices\n");
    [self.serviceBrowser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@"local."];
}

- (void) stopScanning {
    NSLog(@"Stop scanning for devices\n");
    [self.serviceBrowser stop];
    [self.services removeAllObjects];
}

// The following code is adapted from the stackflow Q&A website:
// http://stackoverflow.com/questions/7072989/iphone-ipad-how-to-get-my-ip-address-programmatically
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


@end

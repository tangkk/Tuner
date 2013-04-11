//
//  TunerViewController.m
//  Tuner
//
//  Created by tangkk on 12/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "TunerViewController.h"

#import "PGMidi/PGMidi.h"
#import "PGMidi/PGArc.h"
#import "PGMidi/iOSVersionDetection.h"

#import "MIDINote.h"
#import "VirtualInstrument.h"
#import "Communicator.h"

@interface TunerViewController ()

@property (readwrite) VirtualInstrument *VI;
@property (readwrite) Communicator *CMU;

@end

@implementation TunerViewController

MIDINote *M1, *M2, *M3, *M4, *M5, *M6;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _VI = [[VirtualInstrument alloc] init];
    _CMU = [[Communicator alloc] init];
    
    M1 = [[MIDINote alloc] initWithNote:self.B1.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M2 = [[MIDINote alloc] initWithNote:self.B2.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M3 = [[MIDINote alloc] initWithNote:self.B3.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M4 = [[MIDINote alloc] initWithNote:self.B4.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M5 = [[MIDINote alloc] initWithNote:self.B5.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M6 = [[MIDINote alloc] initWithNote:self.B6.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    
    // If iOS has the feature, initialize coreMIDI with a networkSession
    // note that this PGMidi object is hidden from outside
    IF_IOS_HAS_COREMIDI
    (
     // We only create a MidiInput object on iOS versions that support CoreMIDI
     _CMU.midi = [[PGMidi alloc] init];
     _CMU.midi.networkEnabled = YES;
     )

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    // Nil all the objects
    _VI = nil;
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
    if (_VI) {
        [_VI playMIDI:M1];
    }
    [_CMU sendMidiData:M1];
}

- (IBAction)B2:(id)sender {
    if (_VI) {
        [_VI playMIDI:M2];
    }
    [_CMU sendMidiData:M2];
}

- (IBAction)B3:(id)sender {
    if (_VI) {
        [_VI playMIDI:M3];
    }
    [_CMU sendMidiData:M3];
}

- (IBAction)B4:(id)sender {
    if (_VI) {
        [_VI playMIDI:M4];
    }
    [_CMU sendMidiData:M4];
}

- (IBAction)B5:(id)sender {
    if (_VI) {
        [_VI playMIDI:M5];
    }
    [_CMU sendMidiData:M5];
}

- (IBAction)B6:(id)sender {
    if (_VI) {
        [_VI playMIDI:M6];
    }
    [_CMU sendMidiData:M6];
}

@end

//
//  TunerViewController.m
//  Tuner
//
//  Created by tangkk on 12/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "TunerViewController.h"
#import "MIDINote.h"
#import "VirtualInstrument.h"

@interface TunerViewController ()

@end

@implementation TunerViewController

VirtualInstrument *VI;
MIDINote *M1, *M2, *M3, *M4, *M5, *M6;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    VI = [[VirtualInstrument alloc] init];
    
    M1 = [[MIDINote alloc] initWithNote:self.B1.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M2 = [[MIDINote alloc] initWithNote:self.B2.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M3 = [[MIDINote alloc] initWithNote:self.B3.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M4 = [[MIDINote alloc] initWithNote:self.B4.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M5 = [[MIDINote alloc] initWithNote:self.B5.titleLabel.text duration:1 channel:kChannel_0 velocity:100];
    M6 = [[MIDINote alloc] initWithNote:self.B6.titleLabel.text duration:1 channel:kChannel_0 velocity:100];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    // Nil all the objects
    VI = nil;
    
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
    if (VI) {
        [VI playMIDI:M1];
    }
}

- (IBAction)B2:(id)sender {
    if (VI) {
        [VI playMIDI:M2];
    }
}

- (IBAction)B3:(id)sender {
    if (VI) {
        [VI playMIDI:M3];
    }
}

- (IBAction)B4:(id)sender {
    if (VI) {
        [VI playMIDI:M4];
    }
}

- (IBAction)B5:(id)sender {
    if (VI) {
        [VI playMIDI:M5];
    }
}

- (IBAction)B6:(id)sender {
    if (VI) {
        [VI playMIDI:M6];
    }
}
@end

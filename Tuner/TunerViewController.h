//
//  TunerViewController.h
//  Tuner
//
//  Created by tangkk on 12/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModeSelection.h"
#import "Communicator.h"

@class MIDINote;

@interface TunerViewController : UIViewController  <
#ifdef MASTER
MIDIPlaybackHandle,
NSNetServiceBrowserDelegate
#endif
#ifdef SLAVE
MIDIAssignmentHandle
#endif
>

@property (weak, nonatomic) IBOutlet UIButton *B1;
@property (weak, nonatomic) IBOutlet UIButton *B2;
@property (weak, nonatomic) IBOutlet UIButton *B3;
@property (weak, nonatomic) IBOutlet UIButton *B4;
@property (weak, nonatomic) IBOutlet UIButton *B5;
@property (weak, nonatomic) IBOutlet UIButton *B6;

- (IBAction)B1:(id)sender;
- (IBAction)B2:(id)sender;
- (IBAction)B3:(id)sender;
- (IBAction)B4:(id)sender;
- (IBAction)B5:(id)sender;
- (IBAction)B6:(id)sender;

// These MIDI notes can be normal MIDI note_on note_off or sysEx message
@property (readwrite) MIDINote *M1;
@property (readwrite) MIDINote *M2;
@property (readwrite) MIDINote *M3;
@property (readwrite) MIDINote *M4;
@property (readwrite) MIDINote *M5;
@property (readwrite) MIDINote *M6;
@property (readwrite) MIDINote *M7;
@property (readwrite) MIDINote *M8;

#ifdef MASTER
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
#endif

@end

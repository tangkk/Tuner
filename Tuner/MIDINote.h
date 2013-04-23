//
//  MIDIMessage.h
//  Tuner
//
//  Created by tangkk on 12/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

/*
 This is a MIDINote object to be sent to the AUSampler(the instrument) when the 
 user clicked a note button on the screen. It triggers the instrument to play.
  */

#import <Foundation/Foundation.h>

// Define the mapping of musical root and number, with double letter means "#"
#define Root_C 0
#define Root_CC 1
#define Root_D 2
#define Root_DD 3
#define Root_E 4
#define Root_F 5
#define Root_FF 6
#define Root_G 7
#define Root_GG 8
#define Root_A 9
#define Root_AA 10
#define Root_B 11

#define LOOP_1 60
#define LOOP_2 61

// MIDI Messages' status number
enum {
    kMIDINoteOn = 0x90,
    kMIDINoteOff = 0x80,
    kMIDINoteSysEx = 0xF0,
    kMIDINoteSysExEnd = 0xF7,
    kMIDINoteEdu = 0x7D
};

// MIDI Messages' channel number
enum {
    kChannel_0 = 0x0,
    kChannel_1 = 0x1,
};

@interface MIDINote : NSObject

@property (assign) UInt8 note;
@property (assign) UInt8 duration;
@property (assign) UInt8 channel;
@property (assign) UInt8 velocity;
@property (assign) NSArray *SysEx;
@property (assign) UInt8 Root;


-(id)initWithNote:(UInt8)note duration:(UInt8)duration channel:(UInt8)channel
         velocity:(UInt8)velocity SysEx:(NSArray *)SysEx Root:(UInt8) Root;

@end

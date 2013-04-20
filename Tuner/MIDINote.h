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

// MIDI Messages' status number
enum {
    kMIDINoteOn = 0x9,
    kMIDINoteOff = 0x8,
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


-(id)initWithNote:(UInt8)note duration:(UInt8)duration channel:(UInt8)channel
         velocity:(UInt8)velocity SysEx:(NSArray *)SysEx;

@end

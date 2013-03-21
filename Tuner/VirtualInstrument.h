//
//  AUGraphConsole.h
//  Tuner
//
//  Created by tangkk on 18/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

/*
 This is an a virtual instrument object
 */

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@class MIDINote;

@interface VirtualInstrument : NSObject <AVAudioSessionDelegate>
@property(nonatomic, copy) NSString* currentPresetLabel;

- (void) playMIDI:(MIDINote *) MIDINote;
- (void) setInstrument:(NSString *) InstrumentName;

@end

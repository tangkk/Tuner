//
//  Communicator.h
//  Tuner
//
//  Created by tangkk on 10/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "ModeSelection.h"

@class PGMidi;
@class MIDINote;


@protocol MIDIPlaybackHandle <NSObject>

- (void) MIDIPlayback: (const MIDIPacket *)packet;

@end

@protocol MIDIAssignmentHandle <NSObject>

- (void) MIDIAssignment: (const MIDIPacket *)packet;

@end

@interface Communicator : NSObject

#if ! __has_feature(objc_arc)
@property (nonatomic,assign) PGMidi *midi;
@property (nonatomic,assign) id<MIDIPlaybackHandle> PlaybackDelegate;
@property (nonatomic,assign) id<MIDIAssignmentHandle> AssignmentDelegate;


#else
@property (nonatomic,strong) PGMidi *midi;
@property (nonatomic,strong) id<MIDIPlaybackHandle> PlaybackDelegate;
@property (nonatomic,strong) id<MIDIAssignmentHandle> AssignmentDelegate;
#endif

- (void) sendMidiData:(MIDINote*)midinote;

@end


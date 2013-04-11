//
//  MIDIMessage.m
//  Tuner
//
//  Created by tangkk on 12/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "MIDINote.h"

// Private Declaration
@interface MIDINote ()

@end

@implementation MIDINote

-(id)initWithNote:(NSString *)note duration:(UInt8)duration channel:(UInt8)channel
        velocity:(UInt8)velocity{
    self = [super init];
    if (self) {
        _note = note;
        _duration = duration;
        _channel = channel;
        _velocity = velocity;
        return self;
    }
    return nil;
}

@end
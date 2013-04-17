//
//  Communicator.h
//  Tuner
//
//  Created by tangkk on 10/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PGMidi;
@class MIDINote;

@interface Communicator : NSObject

#if ! __has_feature(objc_arc)
@property (nonatomic,assign) PGMidi *midi;

#else
@property (nonatomic,strong) PGMidi *midi;
#endif

@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;

- (void) sendMidiData:(MIDINote*)midinote;
- (void) playMidiData:(MIDINote*)midinote;

@end

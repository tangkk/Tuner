//
//  AssignmentTable.m
//  Tuner
//
//  Created by tangkk on 19/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "AssignmentTable.h"

// Given a scale name and a key, returns an eight-notes assignment
@implementation AssignmentTable

NSArray *Ionian_1;
NSArray *Ionian_2;

-(id)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    // In the form of MIDI SysEx Message
    Ionian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"E3", @"F3", @"G3", @"A3", @"B3", @"C4", nil];
    Ionian_2 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"F4", @"G4", @"A4", @"B4", @"C5", nil];
    
    _Key = Key_C; // Key C by default
    
    _MusicAssignment = @{
                         @"Ionian_1": Ionian_1,
                         @"Ionian_2": Ionian_2
              };
    return self;
}


@end

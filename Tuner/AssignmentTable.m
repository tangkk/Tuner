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
NSArray *Dorian_1;
NSArray *Dorian_2;
NSArray *Phrygian_1;
NSArray *Phrygian_2;
NSArray *Lydian_1;
NSArray *Lydian_2;
NSArray *Mixolydian_1;
NSArray *Mixolydian_2;
NSArray *Aeolian_1;
NSArray *Aeolian_2;
NSArray *Pentatonic_1;
NSArray *Pentatonic_2;

-(id)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    // In the form of MIDI SysEx Message
    Ionian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"E3", @"F3", @"G3", @"A3", @"B3", @"C4", nil];
    Ionian_2 = [[NSArray alloc] initWithObjects:@"C3", @"E3", @"G3", @"B3", @"C4", @"E4", @"G4", @"B4", nil];
    Dorian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D#3", @"F3", @"G3", @"A3", @"A#3", @"C4", @"D4", nil];
    Dorian_2 = [[NSArray alloc] initWithObjects:@"C4", @"D#4",@"G4", @"A#4", @"C5", @"E5", @"A#5", @"C6", nil];
    Phrygian_1 = [[NSArray alloc] initWithObjects:@"C3", @"C#3", @"D#3", @"F3", @"G3", @"G#3", @"A#3", @"C4", nil];
    Phrygian_2 = [[NSArray alloc] initWithObjects:@"C4", @"C#4", @"F4", @"G4", @"G#4", @"C5", @"C#5", @"F5", nil];
    Lydian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"E3", @"F#3", @"G3", @"A3", @"B3", @"C4", nil];
    Lydian_2 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"F#3", @"G3", @"B3", @"C4", @"D4", @"F#4", nil];
    Mixolydian_1 = [[NSArray alloc] initWithObjects:@"C3", @"D3", @"E3", @"F3", @"G3", @"A3", @"A#3", @"C4", nil];
    Mixolydian_2 = [[NSArray alloc] initWithObjects:@"C3", @"E3", @"G3", @"A#3", @"C4", @"E4", @"G4", @"A#4", nil];
    Aeolian_1 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"D#4", @"F4", @"G4", @"G#4", @"A#4", @"C5", nil];
    Aeolian_2 = [[NSArray alloc] initWithObjects:@"C4", @"D#4", @"F4", @"G4", @"G#4", @"A#4", @"C5", @"D#4", nil];
    Pentatonic_1 = [[NSArray alloc] initWithObjects:@"C4", @"D4", @"E4", @"G4", @"A4", @"C5", @"E5", @"G5", nil];
    Pentatonic_2 = [[NSArray alloc] initWithObjects:@"A5", @"G5", @"E5", @"D5", @"C4", @"D4", @"E4", @"G4", nil];
    
    _MusicAssignment = @{
                         @"Ionian_1": Ionian_1,
                         @"Ionian_2": Ionian_2,
                         @"Dorian_1":Dorian_1,
                         @"Dorian_2":Dorian_2,
                         @"Phrygian_1":Phrygian_1,
                         @"Phrygian_2":Phrygian_2,
                         @"Lydian_1":Lydian_1,
                         @"Lydian_2":Lydian_2,
                         @"Mixolydian_1":Mixolydian_1,
                         @"Mixolydian_2":Mixolydian_2,
                         @"Aeolian_1":Aeolian_1,
                         @"Aeolian_2":Aeolian_2,
                         @"Pentatonic_1":Pentatonic_1,
                         @"Pentatonic_2":Pentatonic_2
              };
    return self;
}


@end

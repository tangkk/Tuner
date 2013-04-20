//
//  AssignmentTable.h
//  Tuner
//
//  Created by tangkk on 19/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <Foundation/Foundation.h>

// Define the mapping of musical key and number, with double means "#"
#define Root_C 1
#define Root_CC 2
#define Root_D 3
#define Root_DD 4
#define Root_E 5
#define Root_F 6
#define Root_FF 7
#define Root_G 8
#define Root_GG 9
#define Root_A 10
#define Root_AA 11
#define Root_B 12

@interface AssignmentTable : NSObject

@property(nonatomic, readonly) NSDictionary *MusicAssignment;
@property(assign)  UInt8 Root;

@end

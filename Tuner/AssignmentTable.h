//
//  AssignmentTable.h
//  Tuner
//
//  Created by tangkk on 19/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <Foundation/Foundation.h>

// Define the mapping of musical key and number, with double means "#"
#define Key_C 1
#define Key_CC 2
#define Key_D 3
#define Key_DD 4

@interface AssignmentTable : NSObject

@property(nonatomic, readonly) NSDictionary *MusicAssignment;
@property(assign)  UInt8 Key;

@end

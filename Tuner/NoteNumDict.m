//
//  NoteNumDict.m
//  Tuner
//
//  Created by tangkk on 10/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import "NoteNumDict.h"

@implementation NoteNumDict

-(id)init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    _Dict = @{
            @"E4":@64,
            @"B3":@59,
            @"G3":@55,
            @"D3":@50,
            @"A2":@45,
            @"E2":@40
            };
//    _antiDict = @{
//            @64:@"E4",
//            @59:@"B3",
//            @55:@"G3",
//            @50:@"D3",
//            @45:@"A2",
//            @40:@"E2"
//            };
    return self;
}

@end

//
//  ModeSelection.h
//  Tuner
//
//  Created by tangkk on 17/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#define TEST
#define MODE2

#ifdef MODE1
    #define MASTER
#endif

#ifdef MODE2
    #define SLAVE
#endif
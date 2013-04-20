//
//  TunerViewController.h
//  Tuner
//
//  Created by tangkk on 12/3/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MIDINote;

@interface TunerViewController : UIViewController  <
#ifdef MASTER
NSNetServiceBrowserDelegate
#endif
@property (weak, nonatomic) IBOutlet UIButton *B1;
@property (weak, nonatomic) IBOutlet UIButton *B2;
@property (weak, nonatomic) IBOutlet UIButton *B3;
@property (weak, nonatomic) IBOutlet UIButton *B4;
@property (weak, nonatomic) IBOutlet UIButton *B5;
@property (weak, nonatomic) IBOutlet UIButton *B6;

- (IBAction)B1:(id)sender;
- (IBAction)B2:(id)sender;
- (IBAction)B3:(id)sender;
- (IBAction)B4:(id)sender;
- (IBAction)B5:(id)sender;
- (IBAction)B6:(id)sender;

#ifdef MASTER
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
#endif

@end

//
//  MasterViewController.h
//  Tuner
//
//  Created by tangkk on 25/4/13.
//  Copyright (c) 2013 tangkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModeSelection.h"
#import "Communicator.h"

@interface MasterViewController : UIViewController<MIDIPlaybackHandle,NSNetServiceBrowserDelegate>

@property (weak, nonatomic) IBOutlet UIButton *Player1;
@property (weak, nonatomic) IBOutlet UIButton *Player2;
@property (weak, nonatomic) IBOutlet UIButton *Player3;
@property (weak, nonatomic) IBOutlet UIButton *Player4;
@property (weak, nonatomic) IBOutlet UIButton *Player5;
@property (weak, nonatomic) IBOutlet UIButton *Player6;

@property (weak, nonatomic) IBOutlet UISlider *Volume;
@property (weak, nonatomic) IBOutlet UISlider *Pan;

@property (weak, nonatomic) IBOutlet UIButton *Groove1;
@property (weak, nonatomic) IBOutlet UIButton *Groove2;
@property (weak, nonatomic) IBOutlet UIButton *Groove3;
@property (weak, nonatomic) IBOutlet UIButton *Groove4;
@property (weak, nonatomic) IBOutlet UIButton *Groove5;
@property (weak, nonatomic) IBOutlet UIButton *Groove6;

@property (weak, nonatomic) IBOutlet UILabel *AssignmentLabel;

@property (weak, nonatomic) IBOutlet UIButton *Start;

@property (weak, nonatomic) IBOutlet UILabel *Debug;
- (IBAction)Player1:(id)sender;
- (IBAction)Player2:(id)sender;
- (IBAction)Player3:(id)sender;
- (IBAction)Player4:(id)sender;
- (IBAction)Player5:(id)sender;
- (IBAction)Player6:(id)sender;

- (IBAction)Groove1:(id)sender;
- (IBAction)Groove2:(id)sender;
- (IBAction)Groove3:(id)sender;
- (IBAction)Groove4:(id)sender;
- (IBAction)Groove5:(id)sender;
- (IBAction)Groove6:(id)sender;

- (IBAction)Start:(id)sender;
- (IBAction)Stop:(id)sender;
- (IBAction)StopAccepting:(id)sender;
- (IBAction)Scan:(id)sender;
- (IBAction)nScan:(id)sender;

- (IBAction)Ionian:(id)sender;
- (IBAction)Dorian:(id)sender;
- (IBAction)Phrygian:(id)sender;
- (IBAction)Lydian:(id)sender;
- (IBAction)MixoLyd:(id)sender;
- (IBAction)Aeolian:(id)sender;
- (IBAction)Pentatonic:(id)sender;
- (IBAction)Blues:(id)sender;
- (IBAction)Harmonics:(id)sender;
- (IBAction)Jazz:(id)sender;
- (IBAction)Arabic:(id)sender;

- (IBAction)Pat1:(id)sender;
- (IBAction)Pat2:(id)sender;
- (IBAction)Pat3:(id)sender;

- (IBAction)C:(id)sender;
- (IBAction)CC:(id)sender;
- (IBAction)D:(id)sender;
- (IBAction)DD:(id)sender;
- (IBAction)E:(id)sender;
- (IBAction)F:(id)sender;
- (IBAction)FF:(id)sender;
- (IBAction)G:(id)sender;
- (IBAction)GG:(id)sender;
- (IBAction)A:(id)sender;
- (IBAction)AA:(id)sender;
- (IBAction)B:(id)sender;

@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;

@end

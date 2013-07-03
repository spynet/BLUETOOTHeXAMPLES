//
//  BTTalkViewController.h
//  BlueToothTalk
//
//  Created by developer on 25/06/13.
//  Copyright (c) 2013 CPT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTTalkViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *messageText;
@property (strong, nonatomic) IBOutlet UITableView *BTList;
@property (strong, nonatomic) IBOutlet UITableView *historyTable;
- (IBAction)ScanNearDevice:(id)sender;
- (IBAction)sendDataToDevice:(id)sender;
- (IBAction)clearList:(id)sender;
- (IBAction)loadDraw:(id)sender;

#pragma mark Voice Chat


- (IBAction)voiceChat:(id)sender;

@end

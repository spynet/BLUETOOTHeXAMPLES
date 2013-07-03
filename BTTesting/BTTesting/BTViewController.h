//
//  BTViewController.h
//  BTTesting
//
//  Created by developer on 26/06/13.
//  Copyright (c) 2013 CPT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
@interface BTViewController : UIViewController
{
GKSession *currentSession;
IBOutlet UITextField *txtMessage;
IBOutlet UIButton *connect;
IBOutlet UIButton *disconnect;
GKPeerPickerController *picker;

}
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) UITextField *txtMessage;
@property (nonatomic, retain) UIButton *connect;
@property (nonatomic, retain) UIButton *disconnect;
-(IBAction) btnSend:(id) sender;
-(IBAction) btnConnect:(id) sender;
-(IBAction) btnDisconnect:(id) sender;
@end

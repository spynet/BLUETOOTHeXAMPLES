//
//  BTViewController.m
//  BTTesting
//
//  Created by developer on 26/06/13.
//  Copyright (c) 2013 CPT. All rights reserved.
//

#import "BTViewController.h"

@interface BTViewController ()<GKPeerPickerControllerDelegate,GKSessionDelegate,UITextFieldDelegate>

@end

@implementation BTViewController
@synthesize currentSession;
@synthesize txtMessage;
@synthesize connect;
@synthesize disconnect;
- (void)viewDidLoad
{
    [connect setHidden:NO];
    [disconnect setHidden:YES];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Button actions

-(IBAction) btnConnect:(id) sender {
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [connect setHidden:YES];
    [disconnect setHidden:NO];
    [picker show];
}

-(IBAction) btnDisconnect:(id) sender
{
    [self.currentSession disconnectFromAllPeers];
//    [self.currentSession release];
    currentSession = nil;
    [connect setHidden:NO];
    [disconnect setHidden:YES];
}

- (void) mySendDataToPeers:(NSData *) data
{
    if (currentSession)
        [self.currentSession sendDataToAllPeers:data
                                   withDataMode:GKSendDataReliable
                                          error:nil];
}

-(IBAction) btnSend:(id) sender
{
    //---convert an NSString object to NSData---
    NSData* data;
    NSString *str = [NSString stringWithString:txtMessage.text];
    data = [str dataUsingEncoding: NSASCIIStringEncoding];
    [self mySendDataToPeers:data];
}

#pragma mark GKPeerPicker delegate 
- (void)peerPickerController:(GKPeerPickerController *)picker1
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *) session {
    self.currentSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    picker.delegate = nil;
    
    [picker dismiss];
//    [picker autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    picker.delegate = nil;
//    [picker autorelease];
    
    [connect setHidden:NO];
    [disconnect setHidden:YES];
}
- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnected:
            NSLog(@"connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"disconnected");
//            [self.currentSession release];
            currentSession = nil;
            
            [connect setHidden:NO];
            [disconnect setHidden:YES];
            break;
    }
}



- (void) receiveData:(NSData *)data
            fromPeer:(NSString *)peer
           inSession:(GKSession *)session
             context:(void *)context {
    
    //---convert the NSData to NSString---
    NSString* str;
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data received"
                                                    message:str
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
//    [alert release];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end

//
//  BTTalkViewController.m
//  BlueToothTalk
//
//  Created by developer on 25/06/13.
//  Copyright (c) 2013 CPT. All rights reserved.
//

#import "BTTalkViewController.h"
#import "BTManager.h"
#import "BTTalkCustomMessageCell.h"
#import "BTTalkMessage.h"
#import "BTTalkCanvasViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
#pragma mark Date class...


@interface Date : NSObject

+(NSString*)getCurrentDate;
@end

@implementation Date

+(NSString*)getCurrentDate
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
    formatter.timeZone = destinationTimeZone;
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mma"];
    return  [formatter stringFromDate:date];
}

@end

///////////////////////////////////////////////////////////////


@interface BTTalkViewController ()<BTManagerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,GKVoiceChatClient>
{
    NSMutableArray* _peers;
    NSMutableArray* _MessageHistory;
    
}
@property BTManager *btManager;
@property GKSession *VChat;
@end

@implementation BTTalkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _btManager = [[BTManager alloc]initWithSessionID:@"myApp"];
    _btManager.delegate = self;
    self.BTList.dataSource  = self;
    self.BTList.delegate    = self;
    _MessageHistory = [[NSMutableArray alloc]init];
    
    // voice chat code
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *myErr;
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&myErr];
    
    [audioSession setActive: YES error: &myErr];
    
    _VChat = [[GKSession alloc] initWithSessionID:@"Sample Session"
                                       displayName:nil sessionMode:GKSessionModePeer]
                    ;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ScanNearDevice:(id)sender
{
    
    _peers = [[_btManager lookForPeers] mutableCopy];
    if(_peers.count > 0)
    {
        [self.BTList reloadData];
    }
    else
        NSLog(@"Unable to load");
}

- (IBAction)sendDataToDevice:(id)sender
{
    for (BTPeer *peer in _peers)
    {
        NSData* data = [self.messageText.text dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSLog(@"Status: %@", [_btManager sendDataToAllPeers:data withDataMode:GKSendDataUnreliable error:&error] ? @"Yes" : @"No");
        
        [_btManager sendData:data toPeer:peer];
        
    }
    BTTalkMessage *msg = [[BTTalkMessage alloc]init];
    msg.messageContent = self.messageText.text;
    msg.peerIDs =  _peers;
    msg.timeStamp = [Date getCurrentDate];
    [_MessageHistory addObject:msg];
    [self.historyTable reloadData];
    
}

- (IBAction)clearList:(id)sender {
    [_btManager disconnectFromAllPeers];
    [_peers removeAllObjects];
    [self.BTList reloadData];
}

- (IBAction)loadDraw:(id)sender
{
    [self.navigationController pushViewController:[[BTTalkCanvasViewController alloc]init] animated:YES];
}


#pragma mark BT
-(void)callMessageWithValue:(NSString*)val withPeerId:(BTPeer*)peerID
{
    BTTalkMessage *msg = [[BTTalkMessage alloc]init];
    msg.messageContent = val;
    msg.peerIDs = [[NSArray alloc]initWithObjects:peerID, nil];
    msg.timeStamp = [Date getCurrentDate];
    [_MessageHistory addObject:msg];
}
-(void)btManager:(BTManager*)btManager finishedReceivingData:(NSData*)data fromPeerName:(NSString *)peer
{
    BTPeer * currentPeer = [[BTPeer alloc]init];
    currentPeer.name = peer;
    NSString* val = [NSString stringWithUTF8String:[data bytes]];
    val ? [self callMessageWithValue:val withPeerId:currentPeer]: NSLog(@"Nil data received");
    [self.historyTable reloadData];
    NSLog(@"The Value:%@",val);
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:val delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}


#pragma mark UITableView Methods...
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.historyTable)
    {
        return [_MessageHistory count];
    }
    else
    {
        return [_peers count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyTable)
    {
        static NSString *cellIdentifier = @"OrderDetailsCell";
        BTTalkCustomMessageCell *cell = (BTTalkCustomMessageCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BTTalkCustomMessageCell" owner:self options:nil];
            
            for (id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell =  (BTTalkCustomMessageCell *) currentObject;
                    break;
                }
            }
        }
        BTTalkMessage *msgData = (BTTalkMessage*)[_MessageHistory objectAtIndex:indexPath.row ];
        cell.content.text = msgData.messageContent;
        cell.senderTimeStamp.text = msgData.timeStamp;
        if ([msgData.peerIDs count] == 1)
        {
            BTPeer *currentPeer = (BTPeer*)[msgData.peerIDs objectAtIndex:0];
            cell.senderName.text = currentPeer.name;
        }
        else
        {
            NSString * peerName;
            for (BTPeer *peer in msgData.peerIDs)
            {
                peerName = [peerName stringByAppendingString:peer.name];
            }
            cell.senderName.text = peerName;
        }
        
//        cell.textLabel.text = [_MessageHistory objectAtIndex:indexPath.row ];
         return cell;
    }
    else
    {
        static NSString *MyIdentifier = @"MyReuseIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
        }
       
        BTPeer *peer = [_peers objectAtIndex:indexPath.row];
        cell.textLabel.text = peer.name;
         return cell;
    }
    
   

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.historyTable)
    {
        NSData* data = [self.messageText.text dataUsingEncoding:NSUTF8StringEncoding];
        [_btManager sendData:data toPeer:[_peers objectAtIndex:indexPath.row]];
        [self callMessageWithValue:self.messageText.text withPeerId:[_peers objectAtIndex:indexPath.row]];
        [self.historyTable reloadData];
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
            if (indexPath.row % 2)
        {
            [cell setBackgroundColor:[UIColor colorWithRed:2.0f/256.0f green:228.0f/256.0f blue:228.0f/256.0f alpha:1]];
        }
        else [cell setBackgroundColor:[UIColor colorWithRed:240.0f/256.0f green:2.0f/256.0f blue:240.f/256.0f alpha:1]];
   
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyTable)
    {
        return 122;
    }
    else
    {
        return 44;
    }
}

- (void)viewDidUnload
{
    [self setMessageText:nil];
    [self setHistoryTable:nil];
    [super viewDidUnload];
}

#pragma mark text field

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)voiceChat:(id)sender
{
//    MyChatClient *myClient = [[MyChatClient alloc] initWithSession: session];
    
    [GKVoiceChatService defaultVoiceChatService].client = self;
    
    NSLog(@"IsVOIP allowed ?  %@", [GKVoiceChatService isVoIPAllowed] ? @"Yes": @"No");
    
// [[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID: otherPeer error: nil];
}

#pragma mark voice chat code

- (NSString *)participantID

{
    
    return _VChat.sessionID ;
    
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID

{
    
    [_VChat sendData: data toPeers:[NSArray arrayWithObject: participantID] withDataMode: GKSendDataReliable error: nil];
    
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context;

{
    
    [[GKVoiceChatService defaultVoiceChatService] receivedData:data fromParticipantID:peer];
    
}

@end

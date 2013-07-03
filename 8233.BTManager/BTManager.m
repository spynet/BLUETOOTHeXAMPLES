//
//  BTManager.m
//
//  Created by Steve Zaharuk on 5/15/13.
//  Copyright (c) 2013 Infragistics Inc. All rights reserved.
//

#import "BTManager.h"

@interface BTManager()<GKPeerPickerControllerDelegate, GKSessionDelegate>
{
    NSData* _dataToSend;
    NSMutableData *_receivedData;
    
    int _totalSizeOfData, _dataBytesSize, _sizeOfDataReceieved;
    
    BOOL _isSender;
    
    GKSession* _hostSession;
    
    BTDataPkg* _dataPkg;
    BOOL _sending;
    NSString* _connectedPeer, *_sessionID;
    
}

@end

@implementation BTManager

-(id)init
{
    self = [super init];

    if(self)
    {
        [self initalizeWithIdentifier:nil];
    }
    
    return self;
}

-(id)initWithSessionID:(NSString*)identifier
{
    self = [super init];
    
    if(self)
    {
        [self initalizeWithIdentifier:identifier];
    }
    
    return self;
}

-(void)initalizeWithIdentifier:(NSString*)identifier
{
    _sessionID = identifier;
    
    _dataBytesSize = 50000;
    [self createSession];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(createSession) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [defaultCenter addObserver:self selector:@selector(endSession) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)createSession
{
    _hostSession = [[GKSession alloc]initWithSessionID:_sessionID displayName:nil sessionMode:GKSessionModePeer];
    _hostSession.available = YES;
    _hostSession.delegate = self;
    [_hostSession setDataReceiveHandler:self withContext:nil];
}

-(void)endSession
{
    [_hostSession disconnectFromAllPeers];
    _hostSession.available = NO;
    _hostSession.delegate = nil;
    _hostSession = nil;
}

-(NSArray*)lookForPeers
{
    NSMutableArray* peers = [[NSMutableArray alloc]init];
    NSArray* peerIds = [_hostSession peersWithConnectionState: GKPeerStateAvailable];
    
    for(NSString* peerId in peerIds)
    {
        BTPeer* peer = [[BTPeer alloc]init];
        peer.identifier = peerId;
        peer.name = [_hostSession displayNameForPeer:peerId];
        [peers addObject:peer];
    }
    
    return peers;
}

-(void)sendMessage:(NSString*)message toPeer:(NSString*)peer
{
    NSData* msgData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_hostSession sendData:msgData toPeers:@[peer] withDataMode:GKSendDataReliable error:nil];
}

-(void)sendData:(NSData*)data toPeer:(BTPeer *)peer
{
    _dataToSend = data;
    [_hostSession connectToPeer:peer.identifier withTimeout:60];
}

-(void)proccessData
{
    if(_dataToSend != nil)
    {
        _isSender = YES;
         _totalSizeOfData = _dataToSend.length;
        
        _dataPkg = [[BTDataPkg alloc]init];
        _dataPkg.currentIndex = 0;
        _dataPkg.dataSent = 0;
        
        _sending = NO;
        
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(btManager:beginSendingData:)])
        {
            [self.delegate btManager:self beginSendingData:_dataToSend];
        }
        
        NSData* msgData = [[NSString stringWithFormat:@"%d", _totalSizeOfData] dataUsingEncoding:NSUTF8StringEncoding];
        [_hostSession sendData:msgData toPeers:@[_connectedPeer] withDataMode:GKSendDataReliable error:nil];
    }
}

-(void)sendChunkToPeer:(NSString*)peer
{
    if(_dataToSend != nil)
    {
        _sending = YES;
                        
        int increment = _dataBytesSize;
        int index = _dataPkg.currentIndex * increment;
        
        if(index + increment > _totalSizeOfData)
        {
            increment = _totalSizeOfData - (index);
        }
        
        _dataPkg.dataSent += increment;
        
        UInt8 bytes[increment];
        [_dataToSend getBytes:&bytes range:NSMakeRange(index, increment)];
        
        NSData* data = [NSData dataWithBytes:bytes length:increment];
        
        NSLog(@"Sending next packet");
        [_hostSession sendData:data toPeers:@[peer] withDataMode:GKSendDataReliable error:nil];
    
        _dataPkg.currentIndex++;
        
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(btManager:percentDataSent:)])
        {
            CGFloat percent = ((CGFloat)_dataPkg.dataSent/(CGFloat)_totalSizeOfData);
            [self.delegate btManager:self percentDataSent:percent];
        }
        
        if(_dataPkg.dataSent == _totalSizeOfData)
        {
            _sending = NO;
            _totalSizeOfData = 0;
            _isSender = NO;
            
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(btManager:finishedSendingData:)])
            {
                [self.delegate btManager:self finishedSendingData:_dataToSend];
            }
            
            _dataToSend = nil;
        }
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    if(!_isSender)
    {
        if(_receivedData == nil)
        {
            _receivedData = [[NSMutableData alloc]initWithCapacity:2048];
            NSString* size = [NSString stringWithUTF8String:[data bytes]];
            _totalSizeOfData = size.intValue;
            
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(btManager:beginReceivingData:)])
            {
                [self.delegate btManager:self beginReceivingData:_totalSizeOfData];
            }
        }
        else
        {
            _sizeOfDataReceieved += data.length;
            [_receivedData appendData:data];
        }
        
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(btManager:percentDataReceived:)])
        {
            CGFloat percent = ((CGFloat)_sizeOfDataReceieved/(CGFloat)_totalSizeOfData);
            [self.delegate btManager:self percentDataReceived:percent];
        }
        
        if(_sizeOfDataReceieved == _totalSizeOfData)
        {
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(btManager:finishedReceivingData:)])
            {
                [self.delegate btManager:self finishedReceivingData:_receivedData];
            }
            
            [session disconnectFromAllPeers];
            [_hostSession disconnectFromAllPeers];
            
            _receivedData = nil;
            _totalSizeOfData = 0;
            _sizeOfDataReceieved = 0;
        }
        else
        {
            NSString* name = [session displayNameForPeer:peer];
            NSLog(@"Received a packet. Notifying: %@", name);
            [self sendMessage:@"got it" toPeer:peer];
        }
    }
    else
    {
        NSString* name = [session displayNameForPeer:peer];
        NSLog(@"Heard back from: %@", name);
        
        [self sendChunkToPeer:peer];
    }
}

-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSString* name = [session displayNameForPeer:peerID];
    NSLog(@"Received Request to Connect To... %@", name);
    NSError* error;
    if(![session acceptConnectionFromPeer:peerID error:&error])
    {
        [self failSend];
        NSLog(@"Error during acceptance: %@", error);
    }
}

-(void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    [self failSend];
    
    [session disconnectFromAllPeers];
    [self createSession];
    NSLog(@"Random Error: %@", error);
}

-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    [self failSend];
    
    NSString* name = [session displayNameForPeer:peerID];
    NSLog(@"Could not connect to: %@ with Error: %@", name, error);
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSString* name = [session displayNameForPeer:peerID];
    switch (state)
    {
        case GKPeerStateConnecting:
        {
            NSLog(@"Connecting to ... %@", name);
            break;
        }
        case GKPeerStateUnavailable:
        {
            [self failSend];
            
            NSLog(@"Unavailable: %@", name);
            break;
        }
        case GKPeerStateConnected:
        {
            _connectedPeer = peerID;
            
            NSLog(@"Connected: %@", name);

            [self proccessData];
            
            break;
        }
        case GKPeerStateDisconnected:
        {
            _connectedPeer = nil;
            
            NSLog(@"Disconnected: %@", name);
            
            break;
        }
        default:
            break;
    }
}

-(void)failSend
{
    if(_sending)
    {
        if(_isSender)
        {
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(btManagerFailedToSendData:)])
            {
                [self.delegate btManagerFailedToSendData:self];
            }
            _isSender = NO;
        }
        else
        {
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(btManagerFailedToReceiveData:)])
            {
                [self.delegate btManagerFailedToReceiveData:self];
            }
            
            _receivedData = nil;
            _sizeOfDataReceieved = 0;
        }
        
        _totalSizeOfData = 0;
        _sending = NO;
    }
}


@end

@implementation BTPeer
@end

@implementation BTDataPkg
@end

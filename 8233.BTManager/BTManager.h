//
//  BTManager.h
//
//  Created by Steve Zaharuk on 5/15/13.
//  Copyright (c) 2013 Infragistics Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class BTManager;

@protocol BTManagerDelegate <NSObject>

@optional

-(void)btManager:(BTManager*)btManager beginSendingData:(NSData*)data;
-(void)btManager:(BTManager*)btManager beginReceivingData:(int)totalSize;

-(void)btManager:(BTManager *)btManager percentDataSent:(CGFloat)percent;
-(void)btManager:(BTManager *)btManager percentDataReceived:(CGFloat)percent;

-(void)btManager:(BTManager *)btManager finishedSendingData:(NSData*)data;
-(void)btManager:(BTManager *)btManager finishedReceivingData:(NSData*)data;

-(void)btManagerFailedToReceiveData:(BTManager*)btManager;
-(void)btManagerFailedToSendData:(BTManager*)btManager;

@end

@interface BTPeer : NSObject

@property(nonatomic, retain)NSString* identifier;
@property(nonatomic, retain)NSString* name;

@end

@interface BTManager : NSObject

-(id)initWithSessionID:(NSString*)identifier;

@property(nonatomic, assign)id<BTManagerDelegate> delegate;
-(NSArray*)lookForPeers;
-(void)sendData:(NSData*)data toPeer:(BTPeer*)peer;

@end




@interface BTDataPkg : NSObject

@property (nonatomic, assign)int currentIndex;
@property (nonatomic, assign)int dataSent;

@end

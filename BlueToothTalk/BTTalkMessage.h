//
//  BTTalkMessage.h
//  BlueToothTalk
//
//  Created by developer on 27/06/13.
//  Copyright (c) 2013 CPT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTTalkMessage : NSObject

@property (nonatomic, strong) NSString *messageContent;
@property (nonatomic, strong) NSArray *peerIDs;
@property (nonatomic, strong) NSString *timeStamp;

@end

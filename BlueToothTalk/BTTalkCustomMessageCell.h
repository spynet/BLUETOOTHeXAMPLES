//
//  BTTalkCustomMessageCell.h
//  BlueToothTalk
//
//  Created by developer on 27/06/13.
//  Copyright (c) 2013 CPT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTTalkCustomMessageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *MSGImag;
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UILabel *senderName;
@property (strong, nonatomic) IBOutlet UILabel *senderTimeStamp;

@end

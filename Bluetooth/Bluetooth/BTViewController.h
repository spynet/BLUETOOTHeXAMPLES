//
//  BTViewController.h
//  Bluetooth
//
//  Created by Radu on 7/12/12.
//  Copyright (c) 2012 Radu Motisan. All rights reserved.
// http://www.pocketmagic.net/?p=2827
//

#import <UIKit/UIKit.h>

///Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.1.sdk/System/Library/PrivateFrameworks/BluetoothManager.framework
//#import <BluetoothManager/BluetoothManager.h>
#import "BluetoothManager.h"
#import "BluetoothDevice.h"
#import "BTListDevItem.h"

@interface BTViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource> {
    // listview attached content array
	NSMutableArray *btDevItems;
    
    // bluetooth manager
    BluetoothManager *btManager;
}
int showMessage(NSString *title, NSString *msg);

-(IBAction)showAbout;
-(IBAction)clearList;
-(IBAction)scanButtonAction;
-(IBAction)bluetoothON;
-(IBAction)bluetoothOFF;

-(void) clearAllList ;
-(void) removeFromList:(NSInteger)index;
-(void) deviceConnect:(NSInteger)index;

@property (nonatomic, retain) NSMutableArray *btDevItems;

@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@end

//
//  BTViewController.m
//  Bluetooth
//
//  Created by Radu on 7/12/12.
//  Copyright (c) 2012 Radu Motisan. All rights reserved.
// http://www.pocketmagic.net/?p=2827

#import "BTViewController.h"
#import "BTAboutViewController.h"


@interface BTViewController ()

@end

@implementation BTViewController


int showMessage(NSString *title, NSString *msg)
{
    UIAlertView *Alert = [[UIAlertView alloc]
                          initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [Alert show];
    return 1;
}

// handle tableview

@synthesize btDevItems;
@synthesize myTableView;

// build one listview cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    for (UIView *unview in cell.contentView.subviews) {
        [unview removeFromSuperview];
    }
    
    //cell.textLabel.text = [btDevItems objectAtIndex:indexPath.row];
    BTListDevItem *item = (BTListDevItem *)[btDevItems objectAtIndex:indexPath.row];
    
    UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(5, 0, 400, 20)];
    label1.text=item.name;
    label1.adjustsFontSizeToFitWidth=YES;
    [cell.contentView addSubview:label1];
    //[label release];
    
    UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(5, 20, 400, 20)];
    label2.text=item.description;
    label2.textColor=[UIColor redColor];
    [cell.contentView addSubview:label2];
    //[tipjob release];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [btDevItems count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTListDevItem *item = (BTListDevItem *)[btDevItems objectAtIndex:indexPath.row];
    
    NSString *message = [NSString stringWithFormat:@"Device %@ [%@]", item.name, item.description];
    
    showMessage(@"Connect to:", message);
    
    [self deviceConnect :( indexPath.row)];
    
}

/* entry point */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init the btDevItems Array
	btDevItems = [[NSMutableArray alloc] init];
    
    // setup bluetooth interface
    btManager = [BluetoothManager sharedInstance];
    
    // setup bluetooth notifications
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(deviceDiscovered:)
     name:@"BluetoothDeviceDiscoveredNotification"
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothAvailabilityChanged:)
     name:@"BluetoothAvailabilityChangedNotification"
     object:nil];
    
    // global notification explorer
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), 
                                    NULL, 
                                    MyCallBack, 
                                    NULL, 
                                    NULL,  
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}
// global notification callback
void MyCallBack (CFNotificationCenterRef center,
                 void *observer,
                 CFStringRef name,
                 const void *object,
                 CFDictionaryRef userInfo) {
    NSLog(@"CFN Name:%@ Data:%@", name, userInfo);
}

/* exit point */
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

/* Listview helper functions */
-(void) clearAllList {
    self.btDevItems = nil;
    [myTableView reloadData];
}

-(void) removeFromList:(NSInteger)index { 
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:btDevItems];
    [tempArray removeObjectAtIndex:index];
    btDevItems = tempArray;
}

/* Keep our GUI in portrait mode */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/* Interface actions - about */
- (IBAction)showAbout {
    // open the BTAboutViewController
    BTAboutViewController *aboutView=[[BTAboutViewController alloc] init];
    UINavigationController *navC=[[UINavigationController alloc] initWithRootViewController:aboutView];
    [self presentModalViewController:navC animated:YES];
}


/* Interface actions - clear listview */
- (IBAction)clearList {
    [self clearAllList];
}

/* Interface actions - scan */
- (IBAction)scanButtonAction {
    if ([btManager enabled]) {
        // clear listview
        [self clearAllList];
        // start scan
        [btManager  setDeviceScanningEnabled:YES];
    } else {
        showMessage(@"Error", @"Turn Bluetooth on first!");
    }

}

/* Interface actions - bt on */
- (IBAction)bluetoothON {
    NSLog(@"bluetoothON called.");
    [btManager setPowered:YES];
    [btManager setEnabled:YES]; 
    
}

/* Interface actions - bt off */
- (IBAction)bluetoothOFF {
    NSLog(@"bluetoothOFF called.");
    //BluetoothManager *manager = [BluetoothManager sharedInstance];
    [btManager setEnabled:NO]; 
    [btManager setPowered:NO];
}

/* Bluetooth notifications */
- (void)bluetoothAvailabilityChanged:(NSNotification *)notification {

    NSLog(@"NOTIFICATION:bluetoothAvailabilityChanged called. BT State: %d", [btManager enabled]);     
}

- (void)deviceDiscovered:(NSNotification *) notification {

    BluetoothDevice *bt = [notification object];
    
    NSLog(@"NOTIFICATION:deviceDiscovered: %@ %@",bt.name, bt.address);

    //create a new list item
    BTListDevItem *item = [[BTListDevItem alloc] initWithName:bt.name description:bt.address type:0 btdev:bt];
    
    //add it to list
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:btDevItems];
    [tempArray addObject:(item)];
    btDevItems = tempArray;
    [myTableView reloadData];
}

/* Bluetooth connectivity */
- (void)deviceConnect:(NSInteger)index { 
    BTListDevItem *item = (BTListDevItem *)[btDevItems objectAtIndex:index];
    NSLog(@"deviceConnect to %@", item.name);
    
    //BluetoothDevice 
    //  [btManager pairDevice:(item.description)];
    
    //  [btManager connectDevice:(item.description)];
    [item.btdev connect];
}
/*
 2012-07-16 19:51:25.364 Bluetooth[706:707] deviceConnect to MOON-PC
 2012-07-16 19:51:25.366 Bluetooth[706:707] BTM: connecting to device "MOON-PC" C4:46:19:C6:39:D1
 2012-07-16 19:51:27.743 Bluetooth[706:707] BTM: attempting to connect to service 0x00000010 on device "MOON-PC" C4:46:19:C6:39:D1
 2012-07-16 19:51:27.751 Bluetooth[706:707] BTM: attempting to connect to service 0x00000008 on device "MOON-PC" C4:46:19:C6:39:D1
 2012-07-16 19:51:28.994 Bluetooth[706:707] BTM: connection to service 0x00000010 on device "MOON-PC" C4:46:19:C6:39:D1 failed with error 305
 2012-07-16 19:51:30.286 Bluetooth[706:707] BTM: connection to service 0x00000008 on device "MOON-PC" C4:46:19:C6:39:D1 failed with error 305
 2012-07-16 19:51:55.841 Bluetooth[706:707] deviceConnect to MOON-PC
 2012-07-16 19:51:55.847 Bluetooth[706:707] BTM: connecting to device "MOON-PC" C4:46:19:C6:39:D1
 2012-07-16 19:51:58.188 Bluetooth[706:707] BTM: attempting to connect to service 0x00000010 on device "MOON-PC" C4:46:19:C6:39:D1
 2012-07-16 19:51:58.193 Bluetooth[706:707] BTM: attempting to connect to service 0x00000008 on device "MOON-PC" C4:46:19:C6:39:D1
 2012-07-16 19:51:59.360 Bluetooth[706:707] BTM: connection to service 0x00000010 on device "MOON-PC" C4:46:19:C6:39:D1 failed with error 305
 2012-07-16 19:52:00.668 Bluetooth[706:707] BTM: connection to service 0x00000008 on device "MOON-PC" C4:46:19:C6:39:D1 failed with error 305
 2012-07-16 19:53:43.483 Bluetooth[706:707] BTM: found device "Celluon " 00:18:E4:27:18:39
 2012-07-16 19:53:43.488 Bluetooth[706:707] NOTIFICATION:deviceDiscovered: Celluon  00:18:E4:27:18:39
 2012-07-16 19:53:45.727 Bluetooth[706:707] deviceConnect to Celluon 
 2012-07-16 19:53:45.732 Bluetooth[706:707] BTM: connecting to device "Celluon " 00:18:E4:27:18:39
 2012-07-16 19:53:47.204 Bluetooth[706:707] BTM: attempting to connect to service 0x00000020 on device "Celluon " 00:18:E4:27:18:39
 2012-07-16 19:53:47.216 Bluetooth[706:707] BTM: connection to service 0x00000020 on device "Celluon " 00:18:E4:27:18:39 failed with error 305
 */


@end

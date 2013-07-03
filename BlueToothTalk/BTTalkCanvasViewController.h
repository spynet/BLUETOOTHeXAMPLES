//
//  BTTalkCanvasViewController.h
//  BlueToothTalk
//
//  Created by developer on 28/06/13.
//  Copyright (c) 2013 CPT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTTalkCanvasViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *containner;
@property (strong, nonatomic) IBOutlet UIView *drawCanvas;

@property (strong, nonatomic) IBOutlet UITableView *dragTable;

- (IBAction)penMenuAction:(id)sender;
- (IBAction)colorPalleteMenuAction:(id)sender;
- (IBAction)saveMenuAction:(id)sender;
- (IBAction)settingMenuAction:(id)sender;
- (IBAction)infoMenuAction:(id)sender;
- (IBAction)undoMenuAction:(id)sender;

- (IBAction)shadowSlider:(UISlider *)sender;
- (IBAction)opacitySlider:(UISlider *)sender;

-(IBAction)loadReOrder:(id)sender;
- (IBAction)toggleColor:(id)sender;
@end

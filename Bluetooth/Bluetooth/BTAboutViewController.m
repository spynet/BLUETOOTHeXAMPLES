//
//  BTAboutViewController.m
//  Bluetooth
//
//  Created by Radu on 7/12/12.
//  Copyright (c) 2012 Radu Motisan. All rights reserved.
// http://www.pocketmagic.net/?p=2827
//

#import "BTAboutViewController.h"


@interface BTAboutViewController ()

@end

@implementation BTAboutViewController

@synthesize myWebView;
@synthesize myTextView;




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.tintColor=[UIColor blackColor];
    self.navigationItem.title=@"Bluetooth Test";
    
    // create a back button
    UIButton *back=[UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [back setFrame:CGRectMake(0, 0, 60, 31)];
    [back addTarget:self action:@selector(gata) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:back];
    
    // set the TextView content
    self.myTextView.text=@"Bluetooth test app for iOS";

    // set webView content
    NSString *thisHtml = @"<hr>(C)2012 Radu Motisan<br><a href=\"http://www.pocketmagic.net/?p=2827\">http://www.pocketmagic.net/?p=2827</a><hr>All rights reserved.<br><b></b><br>v1.0.0";
    [self.myWebView loadHTMLString:thisHtml baseURL:nil];
 
    // create dynamic button
    /*UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     btn.frame = CGRectMake(20,400,88,35); //The position and size of the button (x,y,width,height)
     [btn setTitle:@"Quit" forState:UIControlStateNormal];
     [btn addTarget:self
     action:@selector(showAbout) 
     forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
     [self.view addSubview:btn];*/
}

// functie de iesire
-(void) gata{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

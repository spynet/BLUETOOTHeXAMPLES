//
//  BTTalkCanvasViewController.m
//  BlueToothTalk
//
//  Created by developer on 28/06/13.
//  Copyright (c) 2013 CPT. All rights reserved.
//

#import "BTTalkCanvasViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BTTalkCanvasViewController ()
{
    BOOL _isMenuOpen;
    // touches stuff
    CGPoint _lastPoint;
    CGPoint _currentTouch;
    CGLayerRef commonLayer;
    CGContextRef context1;
    UIImage *drawImage;
    CALayer *sublayer;
    NSMutableArray *layerArray;
    UIColor *currentColor;
}
@end

@implementation BTTalkCanvasViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    NSString *xibName = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"BTTalkCanvasViewController":@"BTTalkCanvasViewController~iphone";
    
    self = [super initWithNibName:xibName bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.containner setFrame:CGRectMake(0,883 , self.containner.frame.size.width, self.containner.frame.size.height)];
    _isMenuOpen = ( self.containner.frame.origin.y == 500 )  ?  YES  :  NO ;
    drawImage =[[UIImage alloc]init];
    sublayer = [CALayer layer];
    sublayer.frame = CGRectMake(0, 0, self.drawCanvas.frame.size.width, self.drawCanvas.frame.size.height);
    sublayer.contents = (id)drawImage.CGImage;
    sublayer.opacity = 0.5;
    sublayer.shadowOpacity = 0.5f;
    [self.drawCanvas.layer insertSublayer:sublayer atIndex:0];
    layerArray = [[NSMutableArray alloc]init];
    currentColor=[UIColor greenColor];
//    [layerArray addObject:sublayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)toggleDecide
{
    [UIView animateWithDuration:0.4f animations:^{
        [self.containner setFrame:CGRectMake(0, _isMenuOpen ? 883 : 500 , self.containner.frame.size.width, self.containner.frame.size.height)];
        
    } completion:^(BOOL finished) {
        _isMenuOpen = !_isMenuOpen  ;
    }];
}

-(IBAction)penMenuAction:(id)sender
{
    [self toggleDecide];
}
-(IBAction)colorPalleteMenuAction:(id)sender
{
   /* --remove Layer--
    for (CALayer * lay in layerArray)
    {
        [UIView animateWithDuration:2.0f animations:^{
            [self.view.layer insertSublayer:lay above:0];
        }];
    
    }
    */
    _isMenuOpen ? nil : [self toggleDecide] ;
 
}
-(IBAction)saveMenuAction:(id)sender
{
    
}
-(IBAction)settingMenuAction:(id)sender
{
    _isMenuOpen ? nil : [self toggleDecide] ;
}
-(IBAction)infoMenuAction:(id)sender
{
    _isMenuOpen ? nil : [self toggleDecide] ;
}

- (IBAction)undoMenuAction:(id)sender
{
    if ( [layerArray count] > 0 )
    {
        [[layerArray lastObject ] removeFromSuperlayer];
        [layerArray removeLastObject];
    }
  
}

- (IBAction)shadowSlider:(UISlider *)sender
{
    sublayer.shadowOpacity = sender.value;
}

- (IBAction)opacitySlider:(UISlider *)sender
{
    sublayer.opacity = sender.value;
}




#pragma mark Touches stuff

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
		UITouch *touch = [touches anyObject];
	_lastPoint = [touch locationInView:self.drawCanvas];
   [self.drawCanvas.layer insertSublayer:sublayer atIndex:0];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _currentTouch = [touch locationInView:self.drawCanvas];
    
    //    [self drawLineFrom:_lastPoint to:_currentTouch width:10];
    
    CGColorRef strokeColor = currentColor.CGColor;
    UIGraphicsBeginImageContext(self.drawCanvas.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [drawImage drawInRect:CGRectMake(0, 0, self.drawCanvas.frame.size.width, self.drawCanvas.frame.size.height)];
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 10);
    
    CGContextSetStrokeColorWithColor(context, strokeColor);
    CGContextSetBlendMode(context, kCGBlendModeColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, _lastPoint.x, _lastPoint.y);
    CGContextAddLineToPoint(context, _currentTouch.x, _currentTouch.y);
    CGContextStrokePath(context);
    drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _lastPoint = [touch locationInView:self.drawCanvas];
    sublayer.contents = (id)drawImage.CGImage;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    CALayer * layer = [CALayer layer];
    layer.frame = sublayer.frame;
    layer.contents = (id) drawImage.CGImage ;
    layer.opacity = sublayer.shadowOpacity;
    layer.shadowOpacity = sublayer.opacity;
    [layerArray addObject:layer];
    //    [self.drawCanvas.layer replaceSublayer:sublayer with:layer];
    [self.drawCanvas.layer insertSublayer:layer atIndex:0];
    drawImage = [[UIImage alloc]init];
    [sublayer removeFromSuperlayer];
    sublayer.contents = (id) drawImage.CGImage ;
//   [self.drawCanvas.layer insertSublayer:sublayer atIndex:0];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEnded:touches withEvent:event];
}

- (void)viewDidUnload {
    [self setDrawCanvas:nil];
    [self setDragTable:nil];
    [super viewDidUnload];
}

#pragma mark line draw code

- (void) drawLineFrom:(CGPoint)from to:(CGPoint)to width:(CGFloat)width
{
	UIGraphicsBeginImageContext(self.drawCanvas.frame.size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
    //	CGContextScaleCTM(ctx, 1.0f, -1.0f);
    //	CGContextTranslateCTM(ctx, 0.0f, -self.drawCanvas.frame.size.height);
	if (drawImage != nil) {
		CGRect rect = CGRectMake(self.drawCanvas.frame.origin.x, self.drawCanvas.frame.origin.y, self.drawCanvas.frame.size.width, self.drawCanvas.frame.size.height);
		CGContextDrawImage(ctx, rect, drawImage.CGImage);
	}
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextSetLineWidth(ctx, width);
	CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
	CGContextMoveToPoint(ctx, from.x, from.y);
	CGContextAddLineToPoint(ctx, to.x, to.y);
	CGContextStrokePath(ctx);
	CGContextFlush(ctx);
	drawImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.drawCanvas.layer.contents = (id)drawImage.CGImage;
}


-(IBAction)loadReOrder:(id)sender
{
    sender = (UIButton*)sender;
    [self.dragTable reloadData];
    [self.dragTable setEditing:!self.dragTable.editing animated:YES];
    
    if (self.dragTable.editing)
    {
        [sender setTitle:@"Edit mode" forState:UIControlStateNormal ];
    }
    else
    {
        [sender setTitle:@"Tap to edit" forState:UIControlStateNormal ];
    }
}

- (IBAction)toggleColor:(UIButton*)sender
{
    if (sender.selected )
    {
        currentColor = [UIColor redColor];
       
    }
    else
    {
        currentColor = [UIColor blueColor];
         
    }
    sender.selected =! sender.selected;

}



#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [layerArray count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DragCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.showsReorderControl = YES;
    }
    
    cell.textLabel.text = [NSString stringWithFormat: @"%d",indexPath.row];//[_list objectAtIndex:indexPath.row];
    
    return  cell;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
//    [self.dragTable.layer replaceSublayer:[layerArray objectAtIndex:sourceIndexPath.row] with:[layerArray objectAtIndex:destinationIndexPath.row]];
    [self removeLayersFromLayersArray:layerArray];
    NSInteger sourceRow = sourceIndexPath.row;
    NSInteger destRow = destinationIndexPath.row;
    id object = [layerArray objectAtIndex:sourceRow];
    
    [layerArray removeObjectAtIndex:sourceRow];
    [layerArray insertObject:object atIndex:destRow];
    [self addLayersToLayersArray:layerArray];
    
}

-(void)removeLayersFromLayersArray:(NSArray*)layersArray
{
    for (CALayer * layerToRemove in layersArray)
    {
        [layerToRemove removeFromSuperlayer];
    }
}
-(void)addLayersToLayersArray:(NSArray*)layersArray
{
    for (CALayer *layerToAdd in layersArray) {
        [self.drawCanvas.layer insertSublayer:layerToAdd atIndex:0];
    }
}
@end

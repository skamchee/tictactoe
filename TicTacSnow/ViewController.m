//
//  ViewController.m
//  TicTacSnow
//
//  Created by Spencer Kamchee on 2/21/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import "ViewController.h"
#import "Marker.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()
@property (strong,nonatomic)NSMutableArray *gridSpots;//of UIViews
@property (strong,nonatomic)NSMutableArray *gridState;//of NSNumbers
@property (strong,nonatomic)NSString *boingSound;
@property (strong,nonatomic)NSString *yaySound;
@property (strong,nonatomic)NSString *pickUpSound;
@property (strong,nonatomic)NSString *snapSound;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.boingSound = [[NSBundle mainBundle] pathForResource:@"Cartoon Timpani" ofType:@"caf"];
    self.yaySound = [[NSBundle mainBundle] pathForResource:@"Kids Cheering" ofType:@"caf"];
    self.snapSound = [[NSBundle mainBundle]pathForResource:@"Computer Data 01" ofType:@"caf"];
    self.pickUpSound = [[NSBundle mainBundle]pathForResource:@"Tink" ofType:@"caf"];
    [self setupGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setupGame{
    //add starting player piece to staging area
    [self addMarker:@"X"];

    //array for views at each grid spot
    self.gridSpots = nil;
    self.gridSpots = [[NSMutableArray alloc]init];
    for(int i=0;i<9;i++)
        [self.gridSpots addObject:[self.view viewWithTag:i+1]];
    
    //array for status of each grid spot (0=empty, 1=filled with X, 4= filled with O)
    self.gridState = nil;
    self.gridState = [[NSMutableArray alloc]initWithObjects:@0,@0,@0,@0,@0,@0,@0,@0,@0, nil];
}

//add a marker to the staging area
-(void)addMarker:(NSString*)markerType{
    CGRect frame;
    if([markerType isEqualToString:@"X"])
        frame = CGRectMake(20, 400, 85, 85);
    else if([markerType isEqualToString:@"O"])
        frame = CGRectMake(200, 400, 85, 85);
    Marker *marker = [[Marker alloc]initWithFrame:frame WithMarker:markerType];
    
    marker.tag=101;//set all the markers with tag 101. to be used later to remove them all from self.view
    [self.view addSubview:marker];
    
    //create a pan gesture and add it to the marker
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMarker:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self]; //set this view as the pan gesture delegate
    [marker addGestureRecognizer:panGesture];
}

//test if the marker intersects with any empty grid spots
-(int)testForIntersection:(Marker*)marker{
    NSMutableArray* intersections = [[NSMutableArray alloc]init];
    for(int i=0; i<9; i++){
        BOOL intersects = CGRectIntersectsRect([self.gridSpots[i] frame], marker.frame);
        if(intersects){
            NSNumber* ni = [NSNumber numberWithInteger:i];
            [intersections addObject:ni];
        }
    }
    if(intersections.count == 1){
        //NSLog(@"Intersection with %d",[[intersections firstObject]intValue]);
        return [[intersections firstObject]intValue];
    }
    return 10;//does not intersect with exactly one grid item
}

-(int)testForWinner{
    NSMutableArray* score = [[NSMutableArray alloc]init];
    
    [score addObject:[NSNumber numberWithInt:[self.gridState[0] intValue] + [self.gridState[1] intValue] + [self.gridState[2] intValue]]];
    [score addObject:[NSNumber numberWithInt:[self.gridState[3] intValue] + [self.gridState[4] intValue] + [self.gridState[5] intValue]]];
    [score addObject:[NSNumber numberWithInt:[self.gridState[6] intValue] + [self.gridState[7] intValue] + [self.gridState[8] intValue]]];
    [score addObject:[NSNumber numberWithInt:[self.gridState[0] intValue] + [self.gridState[3] intValue] + [self.gridState[6] intValue]]];
    [score addObject:[NSNumber numberWithInt:[self.gridState[1] intValue] + [self.gridState[4] intValue] + [self.gridState[7] intValue]]];
    [score addObject:[NSNumber numberWithInt:[self.gridState[2] intValue] + [self.gridState[5] intValue] + [self.gridState[8] intValue]]];
    [score addObject:[NSNumber numberWithInt:[self.gridState[0] intValue] + [self.gridState[4] intValue] + [self.gridState[8] intValue]]];
    [score addObject:[NSNumber numberWithInt:[self.gridState[6] intValue] + [self.gridState[4] intValue] + [self.gridState[2] intValue]]];
    for(int i=0;i<[score count];i++){
        if([score[i] isEqual:@3])
            return 1;//X wins
        if([score[i] isEqual:@12])
            return 2;//O wins
    }
    for(int i=0;i<[self.gridState count];i++){
        if([self.gridState[i] isEqual:@0])
            return 0;//the board is not empty yet, continue playing
    }
    return 3;//no one won, stalemate
}

//This view was set as the pan gesture delegate. this view holds the method panMarker which will control what happens
//when a pan gesture is received by the system
- (void)panMarker:(UIPanGestureRecognizer *)gestureRecognizer
{
    Marker *marker = (Marker*)[gestureRecognizer view];
    [[marker superview] bringSubviewToFront:marker];
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [self playSound:self.pickUpSound];
    }
    
    //Code if the marker is getting moved by the player
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[marker superview]];

        [marker setCenter:CGPointMake([marker center].x + translation.x, [marker center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[marker superview]];
    }
    
    
    //Code if the marker has been set down by the player
    if([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        int location = [self testForIntersection:marker];
        
        if(location<10){
            if([self.gridState[location] isEqual: @1] || [self.gridState[location] isEqual:@4]){
                //A piece is already here. don't allow it. Set the marker back to its starting location
                marker.center = marker.centerPoint;
                [self playSound:self.boingSound];
            }
            else if([self.gridState[location] isEqual:@0]){
                //snap piece to the view
                CGPoint point= [self.gridSpots[location]center];
                [marker setCenter:point];
                marker.userInteractionEnabled = NO; //do not allow the player to change pieces added to grid
                
                //play a sound to confirm the snap to the user
                [self playSound:self.snapSound];
                
                //set the spot as taken, generate the appropriate marker for the next player
                if([marker.markerType isEqualToString:@"X"]){
                    self.gridState[location] = @1;
                    [self addMarker:@"O"];
                }
                else{
                    self.gridState[location] = @4;
                    [self addMarker:@"X"];
                }
                
                int winner = [self testForWinner];
                if(winner){
                    UIAlertView *alertView;
                    if(winner == 1){
                        NSLog(@"Player X wins");
                        [self playSound:self.yaySound];
                        alertView = [[UIAlertView alloc] initWithTitle:@"Winner!" message:@"X Wins!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] ;
                        
                    }
                    if(winner == 2){
                        NSLog(@"Player O wins");
                         [self playSound:self.yaySound];
                        alertView = [[UIAlertView alloc] initWithTitle:@"Winner!" message:@"O Wins!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] ;
                    }
                    if(winner == 3){
                        NSLog(@"No one wins");
                        alertView = [[UIAlertView alloc] initWithTitle:@"Stalemate.." message:@"No one wins!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] ;
                    }
                    alertView.alertViewStyle = UIAlertViewStyleDefault;
                    [alertView show];
                }
            }
        }
        //Move the marker back to its starting point
        if(location == 10){
            marker.center = marker.centerPoint;
            [self playSound:self.boingSound];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //all the play pieces were tagged with number 101
    [self animatePieces:[self.view viewWithTag:101]];
}


-(void)animatePieces:(UIView*) piece{
    //remove all play pieces until none are left, by recursively calling this function
    //because all pieces have the same tag, we cant refer to the next piece until the piece before it has finished animating and removed
    if(piece){
    [UIView animateWithDuration:.2
                          delay:0.02
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [piece setCenter:[self.view center]];
                     }
                     completion:^(BOOL completed){
                         if(completed){
                             [piece removeFromSuperview];
                             [self animatePieces:[self.view viewWithTag:101]];
                         }
                     }];
    }else{
        [self setupGame];
    }
}

void MyAudioServicesAddSystemSoundCompletionProc(SystemSoundID ssID, void *clientData){
    AudioServicesDisposeSystemSoundID(ssID);
}

- (void)playSound:(NSString*) path{
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pathURL, &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, MyAudioServicesAddSystemSoundCompletionProc, NULL);
    AudioServicesPlaySystemSound(soundID);
}

- (void)showActionSheet {
    UIActionSheet *msg = [[UIActionSheet alloc] initWithTitle: @"Two players take alternate turns placing pieces on the grid. First player to complete a straight or diagonal line with three of their pieces wins."
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
    [msg showInView:self.view];
}

- (IBAction)infoButtonPressed:(id)sender {
    [self showActionSheet];
}
@end

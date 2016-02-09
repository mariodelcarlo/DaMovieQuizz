//
//  GameViewController.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "GameViewController.h"
#import "TMDBDownloaderOperation.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "DatabaseHelper.h"
#import "GameLogic.h"

@interface GameViewController () <TMDBDownloaderDelegate, GameLogicDelegate>

@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingActivity;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

//Game logic
@property (nonatomic, retain)GameLogic *gameLogic;

//is currently downloadinf datas
@property (nonatomic, assign)BOOL isDownloading;

//Queue containing database updates (downloading from TMDB)
@property(nonatomic, retain) NSOperationQueue *tmdbQueue;

@end

@implementation GameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.isDownloading = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    //Start download if there is no actor in database
    if([[[DatabaseHelper sharedInstance] getActors] count] == 0){
        self.tmdbQueue = [[NSOperationQueue alloc] init];
        TMDBDownloaderOperation * downloadOp = [[TMDBDownloaderOperation alloc] init];
        downloadOp.delegate =  self;
        [self.tmdbQueue addOperation:downloadOp];
        self.isDownloading = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideWaitingUIElements:!self.isDownloading];
    if(!self.isDownloading){
        [self startGame];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MDBDownloaderDelegate
- (void)didFailedTMDBDownloadWithError:(NSError *)error{
    //TODO
}
    
- (void)didFinishDownloading{
    NSLog(@"NB ACTORS=%d",[[[DatabaseHelper sharedInstance] getActors] count]);
    NSLog(@"NB FILMS %d",[[[DatabaseHelper sharedInstance] getMovies] count]);
    self.isDownloading = NO;
    [self hideWaitingUIElements:YES];
    [self startGame];
    
}

#pragma mark NSManagedObjectContext notification
-(void)contextDidSave:(NSNotification *)notification{
    NSManagedObjectContext * sender = notification.object;
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext  * currentContext = appDelegate.managedObjectContext;
    if (sender != currentContext){
        [currentContext performBlock:^{
            [currentContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark private methods
//Hide or display the UI Elements about waiting the download of elements in database
- (void)hideWaitingUIElements:(BOOL)mustHide{
    if(mustHide){
        [self.waitingActivity stopAnimating];
        self.waitingActivity.alpha = 0;
        self.waitingLabel.alpha = 0;
    }
    else{
        [self.waitingActivity startAnimating];
        self.waitingActivity.alpha = 1;
        self.waitingLabel.alpha = 1;
        [self.waitingLabel setText:NSLocalizedString(@"gameViewControllerWaitingLabel", @"")];
    }
}


-(void)startGame{
    self.gameLogic = [[GameLogic alloc] init];
    self.gameLogic.gameDelegate = self;
    [self.gameLogic startGame];
}

- (NSString*)getTimeStr:(int)secondsElapsed {
    //TODO Check if hour
    int seconds = secondsElapsed % 60;
    int minutes = secondsElapsed / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (NSString*)getQuestionForActor:(NSString*)theActor movie:(NSString*)theMovie{
    return [NSString stringWithFormat:NSLocalizedString(@"gameViewControllerQuestion", @""), theActor, theMovie];
}

//Set the question background color depending on the game step sate in params
-(void)updateQuestionBackgroundForState:(GameStepState)theState{
    if(theState == GameStepFailed){
        self.questionLabel.backgroundColor = [UIColor redColor];
    }
    else if(theState == GameStepWon){
        self.questionLabel.backgroundColor = [UIColor greenColor];
    }
    else{
        self.questionLabel.backgroundColor = [UIColor clearColor];
    }
}




#pragma mark GameLogicDelegate
-(void)displayGameStepWithActor:(NSString*)theActor movie:(NSString*) theMovie state:(GameStepState)theGameState animated:(BOOL)animated{
   
    NSLog(@"displayGameStepWithActor %@",theActor);
    NSString * question = [self getQuestionForActor:theActor movie:theMovie];
    
    [self updateQuestionBackgroundForState:theGameState];
    
    if(animated){
        [self.questionLabel setAlpha:1.0f];
        
        //fade out
        [UIView animateWithDuration:1.0f animations:^{
            [self.yesButton setEnabled:NO];
            [self.noButton setEnabled:NO];
            [self.questionLabel setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            //Disable keyboard
            [self updateQuestionBackgroundForState:GameStepUnknown];
            [self.questionLabel setText:question];
            //fade in
            [UIView animateWithDuration:1.0f animations:^{
                [self.questionLabel setAlpha:1.0f];
                
            } completion:^(BOOL finished){
                [self.yesButton setEnabled:YES];
                [self.noButton setEnabled:YES];
                [self.gameLogic newStepIsDisplayed];
            }];
        }];
    }
    else{
        [self.questionLabel setText:question];
    }
}

-(void)gameEndedWithScore:(NSInteger)theScore lastState:(GameStepState)theGameState{
    //Change background color
    [self updateQuestionBackgroundForState:GameStepFailed];
}

-(void)updateGameTimeSpentWithSeconds:(int)seconds{
    [self.timeLabel setText:[self getTimeStr:seconds]];
}

#pragma mark actions
- (IBAction)yesTouchedUpInside:(id)sender {
    [self.gameLogic validateAnswer:YES];
}

- (IBAction)noTouchedUpInside:(id)sender {
    [self.gameLogic validateAnswer:NO];
}

@end

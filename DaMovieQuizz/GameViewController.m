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
#import <UIImageView+AFNetworking.h>

@interface GameViewController () <TMDBDownloaderDelegate, GameLogicDelegate>

@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingActivity;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnswersLabel;


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

- (void)didFailedTMDBLoadConfiguration{
    UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"gameViewControllerConfigurationError", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    [errorAlertView show];
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

#pragma mark private methods - UI
//Hide or display the UI Elements about waiting the download of elements in database
- (void)hideWaitingUIElements:(BOOL)mustHide{
    if(mustHide){
        [self.waitingActivity stopAnimating];
        self.waitingActivity.alpha = 0;
        self.waitingLabel.alpha = 0;
        self.yesButton.alpha = 1;
        self.yesButton.enabled = YES;
        [self.yesButton setTitle:NSLocalizedString(@"YES",@"") forState:UIControlStateNormal];
        self.noButton.alpha = 1;
        self.noButton.enabled = YES;
        [self.noButton setTitle:NSLocalizedString(@"NO",@"") forState:UIControlStateNormal];
        self.questionLabel.alpha = 1;
        self.timeLabel.alpha = 1;
        self.numberOfAnswersLabel.alpha = 1;
    }
    else{
        [self.waitingActivity startAnimating];
        self.waitingActivity.alpha = 1;
        self.waitingLabel.alpha = 1;
        [self.waitingLabel setText:NSLocalizedString(@"gameViewControllerWaitingLabel", @"")];
        self.yesButton.alpha = 0;
        self.yesButton.enabled = NO;
        self.noButton.alpha = 0;
        self.noButton.enabled = NO;
        self.questionLabel.alpha = 0;
        self.timeLabel.alpha = 0;
        self.numberOfAnswersLabel.alpha = 0;
    }
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


#pragma mark private methods - utils
- (NSString*)getTimeStr:(int)secondsElapsed {
    //TODO Check if hour
    int seconds = secondsElapsed % 60;
    int minutes = secondsElapsed / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (NSString*)getQuestionForActor:(NSString*)theActor movie:(NSString*)theMovie{
    return [NSString stringWithFormat:NSLocalizedString(@"gameViewControllerQuestion", @""), theActor];
}


- (NSString*)getNumberOfAnswersForNumber:(int)theNumber{
    NSString * answersString;
    if(theNumber == 0 || theNumber == 1){
        answersString = [NSString stringWithFormat:NSLocalizedString(@"gameViewControllerAnswers", @""), @""];
    }
    else{
        answersString = [NSString stringWithFormat:NSLocalizedString(@"gameViewControllerAnswers", @""), @"s"];
    }
    return [NSString stringWithFormat:@"%d %@",theNumber,answersString];
}


#pragma mark private methods - others
-(void)startGame{
    self.gameLogic = [[GameLogic alloc] init];
    self.gameLogic.gameDelegate = self;
    [self.gameLogic startGame];
}



#pragma mark GameLogicDelegate
-(void)displayGameStepWithActor:(NSString*)theActor movie:(NSString*)theMovie moviePosterURL:(NSURL*)theUrl stepNumber:(int)theStepNumber state:(GameStepState)theGameState animated:(BOOL)animated{
   
    NSString * question = [self getQuestionForActor:theActor movie:theMovie];
    NSString * numberOfAnswers = [self getNumberOfAnswersForNumber:theStepNumber];
    
    [self updateQuestionBackgroundForState:theGameState];
    
    if(animated){
        [self.questionLabel setAlpha:1.0f];
        
        //fade out
        [UIView animateWithDuration:1.0f animations:^{
            [self.yesButton setEnabled:NO];
            [self.noButton setEnabled:NO];
            [self.posterImageView setAlpha:0.0f];
            [self.questionLabel setAlpha:0.0f];
            [self.numberOfAnswersLabel setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            //Disable keyboard
            [self updateQuestionBackgroundForState:GameStepUnknown];
            [self.questionLabel setText:question];
            [self.numberOfAnswersLabel setText:numberOfAnswers];
            [self.posterImageView setImage:nil]; //we don't want the previous image to be displayed
            [self.posterImageView setImageWithURL:theUrl placeholderImage:nil];
            //fade in
            [UIView animateWithDuration:1.0f animations:^{
                [self.questionLabel setAlpha:1.0f];
                [self.numberOfAnswersLabel setAlpha:1.0f];
                [self.posterImageView setAlpha:1.0f];
                
            } completion:^(BOOL finished){
                [self.yesButton setEnabled:YES];
                [self.noButton setEnabled:YES];
                [self.gameLogic newStepIsDisplayed];
            }];
        }];
    }
    else{
        [self.posterImageView setImage:nil];
        [self.posterImageView setImageWithURL:theUrl placeholderImage:nil];
        [self.numberOfAnswersLabel setText:numberOfAnswers];
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

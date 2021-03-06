//
//  GameViewController.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "GameViewController.h"
#import "TMDBDownloaderOperation.h"
#import "AppDelegate.h"
#import "DatabaseHelper.h"
#import "GameLogic.h"
#import <UIImageView+AFNetworking.h>
#import "GameSummaryViewController.h"
#import "Utils.h"

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

#pragma marks view life cycle methods
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
    [self hideWaitingUIElements:NO];
    if(!self.isDownloading){
        [self startGame];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TMDBDownloaderDelegate
- (void)didFailedTMDBDownloadWithError:(NSError *)error forPage:(int)page{
    __weak GameViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * message = [NSString stringWithFormat:NSLocalizedString(@"gameViewControllerDownloadActorError", @""),page];
        UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:message delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
        [errorAlertView show];
    });
}

- (void)didFailedTMDBLoadConfiguration{
    __weak GameViewController *weakSelf = self;
     dispatch_async(dispatch_get_main_queue(), ^{
         UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"gameViewControllerConfigurationError", @"") delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
         [errorAlertView show];
     });
}

- (void)didFinishDownloading{
    __weak GameViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.isDownloading = NO;
        [weakSelf startGame];
    });
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

#pragma mark methods - UI
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
        self.posterImageView.alpha = 1;
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
        self.posterImageView.alpha = 0;
    }
}

//Set the question background color depending on the game step sate in params
-(void)updateQuestionBackgroundForState:(GameStepState)theState{
    if(theState == GameStepFailed){
        self.questionLabel.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
    }
    else if(theState == GameStepWon){
        self.questionLabel.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    }
    else{
        self.questionLabel.backgroundColor = [UIColor clearColor];
    }
}


#pragma mark methods - utils
- (NSString*)getQuestionForActor:(NSString*)theActor movie:(NSString*)theMovie{
    return [NSString stringWithFormat:NSLocalizedString(@"gameViewControllerQuestion", @""), theActor];
}


- (NSString*)getNumberOfAnswersForNumber:(int)theNumber{
    return [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"gameViewControllerAnswers", @""),theNumber];
}

-(void)startGame{
    self.gameLogic = [[GameLogic alloc] init];
    self.gameLogic.gameDelegate = self;
    [self.gameLogic initGame];
}


#pragma mark GameLogicDelegate
//Called when the game is about to be launched
-(void)gameIsAboutToBelaunched{
    [self hideWaitingUIElements:YES];
}

//Called for displaying UI ELements with appropriate datas
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
            [self.timeLabel setAlpha:0.0f];
            
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
                [self.timeLabel setAlpha:1.0f];
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

//Called when the game ends
-(void)gameEndedWithScore:(NSInteger)theScore timeElapsedInSeconds:(int)seconds{
    //Change background color
    [self updateQuestionBackgroundForState:GameStepFailed];
    
    //Disable buttons
    [self.yesButton setEnabled:NO];
    [self.noButton setEnabled:NO];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    GameSummaryViewController *dest = [storyboard instantiateViewControllerWithIdentifier:@"gameSummaryID"];
    dest.secondsSpent = seconds;
    dest.numberOfAnswers = theScore;
    [self.navigationController pushViewController:dest animated:YES];
}

//Called whne the game logic time is updated (every seconds)
-(void)updateGameTimeSpentWithSeconds:(int)seconds{
    [self.timeLabel setText:[Utils getTimeStringFromSeconds:seconds]];
}

#pragma mark actions
- (IBAction)yesTouchedUpInside:(id)sender {
    [self.gameLogic validateAnswer:YES];
}

- (IBAction)noTouchedUpInside:(id)sender {
    [self.gameLogic validateAnswer:NO];
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}

@end

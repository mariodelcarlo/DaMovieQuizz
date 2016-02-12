//
//  GameLogic.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "GameLogic.h"
#import "Game.h"
#import "GameStep.h"
#import "DatabaseHelper.h"
#import <JLTMDbClient.h>
#import "Constants.h"

@implementation GameLogic

#pragma mark init methods
- (id)init{
    self = [super init];
    if (self) {
        self.currentGameStep = 0;
        self.gameElapsedTime = 0;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepIsReady:) name:@"GAME_STEP_READY" object:nil];
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark methods relatives to game

//Init a new game
-(void)initGame{
    //Create a game
    self.currentGame = [[Game alloc] init];
    
    //Launch the steps init
    [self initSteps];
}


//Init steps for the current game
-(void)initSteps{
    //Start to prepare NUMBER_OF_PREPARED_STEPS questions
    for (int nb_questions = 0; nb_questions < NUMBER_OF_PREPARED_STEPS; nb_questions ++) {
        GameStep * step = [[GameStep alloc] init];
        [step initGameStep];
    }
}

-(void)launchGame{
    if(self.gameDelegate != nil && [self.gameDelegate respondsToSelector:@selector(gameIsAboutToBelaunched)]){
        [self.gameDelegate gameIsAboutToBelaunched];
    }
    
    //Start the timer
    if(self.currentGameTimer !=nil){
        [self.currentGameTimer invalidate];
        self.currentGameTimer = nil;
    }
    self.currentGameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [self.currentGameTimer fire];
    
    if(self.gameDelegate != nil && [self.gameDelegate respondsToSelector:@selector(displayGameStepWithActor:movie:moviePosterURL:stepNumber:state:animated:)]){
        
        //Display first step of the game
        GameStep * step1 = self.currentGame.steps[0];
        NSURL * posterURL = nil;
        
        if(step1.posterPath != nil){
            posterURL = [self moviePosterURLForPath:step1.posterPath];
        }
        
        [self.gameDelegate displayGameStepWithActor:step1.actorName movie:step1.movieTitle moviePosterURL:posterURL stepNumber:self .currentGameStep state:GameStepUnknown animated:NO];
    }
    self.currentGame.isPlaying = YES;
}


-(void)endGame{
    if(self.currentGameTimer !=nil){
        [self.currentGameTimer invalidate];
        self.currentGameTimer = nil;
    }
    self.currentGame.isPlaying = NO;
}



//Timer
-(void)timerTick:(NSTimer *)timer {
    self.gameElapsedTime = self.gameElapsedTime + 1;
    if(self.gameDelegate != nil && [self.gameDelegate respondsToSelector:@selector(updateGameTimeSpentWithSeconds:)]){
        [self.gameDelegate updateGameTimeSpentWithSeconds:self.gameElapsedTime];
    }
}



//Method to show the next step if exists or ends game
-(void)showNextStepWithState:(GameStepState)theState{

    if(theState == GameStepFailed) {
        //Stop the timer
        [self endGame];
        
        //The game is finished
        if(self.gameDelegate != nil && [self.gameDelegate respondsToSelector:@selector(gameEndedWithScore:timeElapsedInSeconds:)]){
            [self.gameDelegate gameEndedWithScore:self.currentGame.score timeElapsedInSeconds:self.gameElapsedTime];
        }
    }
    else{
        //Change the step
        self.currentGameStep = self.currentGameStep + 1;
        
        //Get left steps number, add more steps if needed
        NSInteger leftSteps = self.currentGame.steps.count - self.currentGameStep;
        if(leftSteps < 2){
            [self initSteps];
        }
        
        if(self.gameDelegate != nil && [self.gameDelegate respondsToSelector:@selector(displayGameStepWithActor:movie:moviePosterURL:stepNumber:state:animated:)]){
            
            //Display next step of the game
            GameStep * stepNew = self.currentGame.steps[self.currentGameStep];
            NSURL *posterURL = nil;
            
            if(stepNew.posterPath != nil){
                posterURL =[self moviePosterURLForPath:stepNew.posterPath];
            }
            
            [self.gameDelegate displayGameStepWithActor:stepNew.actorName movie:stepNew.movieTitle moviePosterURL:posterURL stepNumber:self.currentGameStep state:theState animated:YES];
        }
    }
}

//Checks if an answer is right or not, and call the right method depending if the game step
//is won or not
-(void)validateAnswer:(BOOL)theAnswer{
    GameStep * step1 = self.currentGame.steps[self.currentGameStep];
    if([step1 rightAnswer] == theAnswer){
        //WON THE STEP
        self.currentGame.score = self.currentGame.score + 1;
        [self showNextStepWithState:GameStepWon];
    }
    else{
        //LOOSE THE GAME
        [self showNextStepWithState:GameStepFailed];
    }
}

//Called when a new step has been displayed and the animation is finished
-(void)newStepIsDisplayed{
}



-(void)stepIsReady:(id)notication{
    GameStep *gameStep = [notication object];
    if(gameStep != nil){
        [self.currentGame.steps addObject:gameStep];
        NSLog(@"%@ %@ -> %d",gameStep.actorName,gameStep.movieTitle,gameStep.rightAnswer);
    }
    self.currentStepsReady = self.currentStepsReady + 1;
    
    if(self.currentStepsReady == NUMBER_OF_PREPARED_STEPS){
        if(!self.currentGame.isPlaying){
            [self launchGame];
        }
    }
}

#pragma mark utils
//Get movie poster url for a poster path given
- (NSURL *)moviePosterURLForPath:(NSString *)theShortPath{
    NSString * imageBase = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_IMAGE_URL_KEY];
    NSString  * posterImage = [imageBase stringByAppendingString:@"w500"];
    NSURL *theURL = [NSURL URLWithString:[posterImage stringByAppendingString:theShortPath]];
    return theURL;
}
@end

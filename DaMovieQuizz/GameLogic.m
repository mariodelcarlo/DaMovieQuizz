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
    return self;
}

#pragma mark private methods

//Create a game with 10 steps already loaded
- (void)createGame{
    self.currentGame = [[Game alloc] init];
   
    //Prepare 10 questions
    NSMutableArray * steps = [[NSMutableArray alloc] init];
    for (int nb_questions = 0; nb_questions < 10; nb_questions ++) {
        GameStep * step = [self createGameStep];
        if(step != nil){
            [steps addObject:step];
        }
    }
    [self.currentGame setSteps:steps];
}

//Create a game step: choose an Actor, a film and save the right answer
//returns the GameStep created
-(GameStep*)createGameStep{
    
    //We find a random famous actor
    Actor * randomActor = [[DatabaseHelper sharedInstance] getRandomActor];
    //We find a random movie in which the famous actor has played
    Movie * randomMovie = [[DatabaseHelper sharedInstance] getRandomMovieForActor:randomActor];
    //We find a random movie in which the famous actor has not played
    Movie * randomMovieWithoutActor = [[DatabaseHelper sharedInstance] getRandomMovieWithoutActor:randomActor];
    
    NSString * movieTitleChoosen = nil;
    NSString * posterPath = nil;
    BOOL rightAnswer = NO;
    //We choose randomly between this these 2 films->50% of chance the actor has played in the film and 50% he has not played
    int randomNumber = (int)[[DatabaseHelper sharedInstance] randomNumberBetween:0 maxNumber:1];
    
    if(randomNumber == 0){
        movieTitleChoosen = randomMovie.title;
        rightAnswer = YES;
        posterPath = randomMovie.posterPath;
    }
    else{
        movieTitleChoosen = randomMovieWithoutActor.title;
        rightAnswer = NO;
        posterPath = randomMovieWithoutActor.posterPath;
    }
    
    NSLog(@"Question=Est-ce que %@ a joué dans %@? -> %d",randomActor.name,movieTitleChoosen,rightAnswer);
    
    GameStep * newGameStep = [[GameStep alloc] init];
    newGameStep.actorName = randomActor.name;
    newGameStep.movieTitle = movieTitleChoosen;
    newGameStep.rightAnswer = rightAnswer;
    newGameStep.posterPath = posterPath;
    
    return newGameStep;
}


-(void)startGame{
    //Create a game
    [self createGame];
    
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
}


-(void)timerTick:(NSTimer *)timer {
    self.gameElapsedTime = self.gameElapsedTime + 1;
    if(self.gameDelegate != nil && [self.gameDelegate respondsToSelector:@selector(updateGameTimeSpentWithSeconds:)]){
        [self.gameDelegate updateGameTimeSpentWithSeconds:self.gameElapsedTime];
    }
}

-(void)endGame{
    if(self.currentGameTimer !=nil){
        [self.currentGameTimer invalidate];
        self.currentGameTimer = nil;
    }
}

-(void)resumeGame{
    
}

-(void)pauseGame{
    if(self.currentGameTimer !=nil){
        [self.currentGameTimer invalidate];
        self.currentGameTimer = nil;
    }
}


//Method to show the next step if exists or ends game
-(void)showNextStepWithState:(GameStepState)theState{

    //TODO THE GAME MUST BE ENDLESS
    if(theState == GameStepFailed) {
        //Stop the timer
        [self endGame];
        
        NSLog(@"LOOSE THE GAME");
        //The game is finished
        if(self.gameDelegate != nil && [self.gameDelegate respondsToSelector:@selector(gameEndedWithScore: lastState:)]){
            [self.gameDelegate gameEndedWithScore:self.currentGame.score lastState:theState];
        }
    }
    else{
        //Go to the next step if there is one left
        if(self.currentGameStep < self.currentGame.steps.count - 1){
            //Change the step
            self.currentGameStep = self.currentGameStep + 1;
            
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
        else{
            //The game is finished
            if(self.gameDelegate != nil && [self.gameDelegate respondsToSelector:@selector(gameEndedWithScore: lastState:)]){
                [self.gameDelegate gameEndedWithScore:self.currentGame.score lastState:theState];
            }
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
    /*//Start the timer
     if(self.currentStepTimer !=nil){
     [self.currentStepTimer invalidate];
     self.currentStepTimer = nil;
     }
     self.currentStepTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(stepTimerTick:) userInfo:nil repeats:YES];
     [self.currentStepTimer fire];*/
}

- (NSURL *)moviePosterURLForPath:(NSString *)theShortPath{
    NSString * imageBase = [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEFAULTS_IMAGE_URL_KEY];
    NSString  * posterImage = [imageBase stringByAppendingString:@"w500"];
    NSURL *theURL = [NSURL URLWithString:[posterImage stringByAppendingString:theShortPath]];
    return theURL;
}

@end

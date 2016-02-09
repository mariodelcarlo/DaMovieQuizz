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

@implementation GameLogic

#pragma mark init methods
- (id)init{
    self = [super init];
    if (self) {
        self.currentGameStep = 0;
    }
    return self;
}

#pragma mark private methods

//Create a game with 10 steps already loaded
- (void)createGame{
    NSLog(@"CREATE GAME");
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
    BOOL rightAnswer = NO;
    //We choose randomly between this these 2 films->50% of chance the actor has played in the film and 50% he has not played
    int randomNumber = (int)[[DatabaseHelper sharedInstance] randomNumberBetween:0 maxNumber:1];
    
    if(randomNumber == 0){
        movieTitleChoosen = randomMovie.title;
        rightAnswer = YES;
    }
    else{
        movieTitleChoosen = randomMovieWithoutActor.title;
        rightAnswer = NO;
    }
    
    NSLog(@"Question=Est-ce que %@ a joué dans %@? -> %d",randomActor.name,movieTitleChoosen,rightAnswer);
    
    GameStep * newGameStep = [[GameStep alloc] init];
    newGameStep.actorName = randomActor.name;
    newGameStep.movieTitle = movieTitleChoosen;
    newGameStep.rightAnswer = rightAnswer;
    
    return newGameStep;
}


-(void)startGame{
    NSLog(@"START GAME");
    
    //Create a game
    [self createGame];
    
    //Start the timer
    if(self.currentGameTimer !=nil){
        [self.currentGameTimer invalidate];
        self.currentGameTimer = nil;
    }
    self.currentGameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [self.currentGameTimer fire];
}


-(void)timerTick:(NSTimer *)timer {
    //NSLog(@"timerTick");
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



@end

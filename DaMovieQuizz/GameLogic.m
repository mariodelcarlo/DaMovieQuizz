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
    Actor * randomActor = [[DatabaseHelper sharedInstance] getRandomActor];
    NSLog(@"randomActor=%@",randomActor.name);
    
    GameStep * newGameStep = [[GameStep alloc] init];
    newGameStep.actorName = randomActor.name;
    
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

//
//  GameLogic.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "GameStep.h"

@protocol GameLogicDelegate <NSObject>
-(void)displayGameStepWithActor:(NSString*)theActor movie:(NSString*)theMovie moviePosterURL:(NSURL*)theUrl stepNumber:(int)theStepNumber state:(GameStepState)theGameState animated:(BOOL)animated;
-(void)gameEndedWithScore:(NSInteger)theScore timeElapsedInSeconds:(int)seconds;
-(void)updateGameTimeSpentWithSeconds:(int)seconds;
-(void)gameIsAboutToBelaunched;
@end

@interface GameLogic : NSObject

//current game
@property (nonatomic,retain) Game * currentGame;
//current game step
@property (nonatomic,assign) int currentGameStep;
//game delegate
@property(nonatomic,assign) id <GameLogicDelegate> gameDelegate;
//Timer for the game
@property(nonatomic, retain) NSTimer *currentGameTimer;
//Counter for the current game elapsed time in seconds
@property(nonatomic, assign) int gameElapsedTime;
//Number of steps ready
@property (nonatomic,assign) int currentStepsReady;

-(void)initGame;
-(void)endGame;
-(void)newStepIsDisplayed;
-(void)validateAnswer:(BOOL)theAnswer;

@end

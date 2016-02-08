//
//  GameLogic.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@interface GameLogic : NSObject

@property (nonatomic,retain) Game * currentGame;

@property (nonatomic,assign) int currentGameStep;

//Timer for the game
@property(nonatomic, retain) NSTimer *currentGameTimer;

-(void)startGame;
-(void)endGame;
-(void)resumeGame;
-(void)pauseGame;

@end

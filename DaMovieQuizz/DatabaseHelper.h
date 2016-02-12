//
//  DatabaseHelper.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Movie.h"

@interface DatabaseHelper : NSObject
+ (id)sharedInstance;
- (NSArray *)getActors;
-(Actor*)getRandomActor;
-(Movie*)getRandomMovieForActor:(Actor *)actor;
-(Movie*)getRandomMovieWithActor:(Actor*)actor1 withoutActor:(Actor *)actor2;
- (NSArray *)getHighScores;
-(BOOL)isAnHighScoreForScore:(NSInteger)theScore time:(NSInteger)theTime;

-(BOOL)saveHighScoreWithPlayerName:(NSString*)thePlayerName score:(NSInteger)theScore time:(NSInteger)theTime;

@end

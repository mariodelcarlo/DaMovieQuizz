//
//  Game.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Game : NSObject

//Enum for the state of the game
typedef NS_ENUM(NSUInteger, GameState) {
    GameWon = 0,
    GameFailed = 1,
    GameUnknown = 2
};

//The steps
@property(nonatomic, retain) NSMutableArray * steps;

//Score
@property(nonatomic, assign) NSInteger score;


//Indicates if the game is playing
@property(nonatomic, assign)BOOL isPlaying;

@end

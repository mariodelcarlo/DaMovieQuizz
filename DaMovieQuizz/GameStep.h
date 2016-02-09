//
//  GameStep.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>

//Enum for the state of the game
typedef NS_ENUM(NSUInteger, GameStepState) {
    GameStepWon = 0,
    GameStepFailed = 1,
    GameStepUnknown = 2
};

@interface GameStep : NSObject

//Actor choosen
@property(nonatomic, copy)NSString * actorName;

//Movie choosen
@property(nonatomic, copy)NSString * movieTitle;

//Poster path
@property(nonatomic, copy)NSString * posterPath;

//Right answer
@property(nonatomic, assign) BOOL rightAnswer;


@end

//
//  GameStep.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import <JLTMDbClient.h>


//Enum for the state of the game
typedef NS_ENUM(NSUInteger, GameStepState) {
    GameStepWon = 0,
    GameStepFailed = 1,
    GameStepUnknown = 2
};

@interface GameStep : NSObject

//Properties needed when building the step
//Number of films downoaded for an actor
@property(nonatomic, assign)int numberOfActorFilmsDownloaded;
//First random actor choosen
@property(nonatomic,retain)Actor * randomActor1;
//Second random actor choosen
@property(nonatomic,retain)Actor * randomActor2;
//Actor definitively choosen
@property(nonatomic,retain)Actor * choosenActor;

//Name of the actor choosen
@property(nonatomic, copy)NSString * actorName;

//Movie choosen
@property(nonatomic, copy)NSString * movieTitle;

//Poster path
@property(nonatomic, copy)NSString * posterPath;

//Right answer
@property(nonatomic, assign) BOOL rightAnswer;

-(void)initGameStep;
@end

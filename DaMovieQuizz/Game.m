//
//  Game.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "Game.h"

@implementation Game

//Init method
- (id)init{
    self = [super init];
    if (self) {
        self.score = 0;
        self.timeSpentInSeconds = 0;
        self.gameState = GameUnknown;
        self.numberOfRightAnswers = 0;
        self.steps = [[NSMutableArray alloc] init];
        self.isPlaying =  NO;
    }
    return self;
}

@end

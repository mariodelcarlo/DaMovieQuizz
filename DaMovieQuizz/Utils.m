//
//  Utils.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 10/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(NSString*)getTimeStringFromSeconds:(int)secondsElapsed{
    //TODO: Check if hour
    int seconds = secondsElapsed % 60;
    int minutes = secondsElapsed / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

//Generate a random number between 2 bounds, bounds are included
+ (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max{
    //arc4random_uniform returns value between 0 and the bounds set in parameter
    return min + arc4random_uniform((int)max - (int)min + 1);
}

@end

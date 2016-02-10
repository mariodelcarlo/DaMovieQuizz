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
    //TODO Check if hour
    int seconds = secondsElapsed % 60;
    int minutes = secondsElapsed / 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

@end

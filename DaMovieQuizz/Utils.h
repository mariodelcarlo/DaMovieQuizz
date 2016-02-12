//
//  Utils.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 10/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject
+(NSString*)getTimeStringFromSeconds:(int)secondsElapsed;
+(NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max;
@end

//
//  DatabaseHelper.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseHelper : NSObject
+ (id)sharedInstance;
- (NSArray *)getActors;
- (NSArray *)getMovies;
@end

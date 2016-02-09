//
//  GameStep.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameStep : NSObject

//Actor choosen
@property(nonatomic, assign)NSString * actorName;

//Movie choosen
@property(nonatomic, assign)NSString * movieTitle;

//Right answer
@property(nonatomic, assign) BOOL rightAnswer;


@end

//
//  GameSummaryViewController.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 09/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameSummaryViewController : UIViewController<UITextFieldDelegate>
@property(nonatomic,assign) NSInteger numberOfAnswers;
@property(nonatomic,assign) int secondsSpent;
@end

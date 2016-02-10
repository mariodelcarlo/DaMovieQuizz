//
//  HighScoreTableViewCell.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 10/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoreTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

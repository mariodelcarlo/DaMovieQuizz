//
//  GameSummaryViewController.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 09/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "GameSummaryViewController.h"
#import "Utils.h"
#import "DatabaseHelper.h"
#import  "Constants.h"
#import  "HighScore.h"

@interface GameSummaryViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSpentLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoresLabel;
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UISwitch *highScoresSwitch;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnswersLabel;
@end

@implementation GameSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.titleLabel setText:NSLocalizedString(@"gameSummaryTitleLabel", @"")];
    [self.timeSpentLabel setText:[NSString stringWithFormat:NSLocalizedString(@"gameSummaryTimeSpentLabel", @""), [Utils getTimeStringFromSeconds:self.secondsSpent]]];
    [self.numberOfAnswersLabel setText:[NSString stringWithFormat:NSLocalizedString(@"gameSummaryNumberOfAnswers", @""), self.numberOfAnswers]];
    [self.playAgainButton setTitle:NSLocalizedString(@"gameSummaryPlayAgainButton", @"") forState:UIControlStateNormal];
    [self.nameLabel setText:NSLocalizedString(@"gameSummaryNameLabel", @"")];
    [self.highScoresLabel setText:NSLocalizedString(@"gameSummaryHighScoresLabel", @"")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark actions
- (IBAction)playAgainTouchedUpInside:(id)sender {
    if(self.highScoresSwitch.isOn && self.nameTextField.text && self.nameTextField.text.length == 0){
        UIAlertView * errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"gameSummaryNameAlertTitle", @"") message:NSLocalizedString(@"gameSummaryNameAlertMessage", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
        [errorAlertView show];
    }
    else{
        if(self.highScoresSwitch.isOn && [self isAnHighScore]){
            NSLog(@"THIS IS AN HIGHSCORE");
            //Save in database
            if(![[DatabaseHelper sharedInstance] saveHighScoreWithPlayerName:self.nameTextField.text score:self.numberOfAnswers time:self.secondsSpent]){
                //TODO ALERT THE USER
            }
        }
        [self performSegueWithIdentifier:@"unwindToGame" sender:self];
    }
}

- (IBAction)switchChanged:(id)sender {
    [self updateHighscoresNameDependingSwitch];
}

#pragma mark private methods
-(void)updateHighscoresNameDependingSwitch{
    if(self.highScoresSwitch.isOn){
        self.nameLabel.alpha = 1;
        self.nameTextField.alpha = 1;
        self.nameTextField.enabled = YES;
    }
    else{
        self.nameLabel.alpha = 0;
        self.nameTextField.alpha = 0;
        self.nameTextField.enabled = NO;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)isAnHighScore{
    if(self.highScoresSwitch.isOn){
        NSArray * highScores = [[DatabaseHelper sharedInstance] getHighScores];
        if(highScores.count < NUMBER_OF_HIGHSCORES){
            return YES;
        }
        HighScore * lowHighScore = highScores[0];
        NSLog(@"lowHighScore=%d %@",[lowHighScore.score intValue],lowHighScore.playerName);
        if((int)self.numberOfAnswers > [lowHighScore.score intValue]){
            return YES;
        }
    }
    return NO;
}
@end

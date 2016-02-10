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
#import "Constants.h"
#import "HighScore.h"
#import "HighScoresViewController.h"

@interface GameSummaryViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSpentLabel;
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
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
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self isAnHighScore]){
        
        //Show alert to get the name
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"gameSummaryNameAlertTitle", @"") message:NSLocalizedString(@"gameSummaryNameAlertMessage", @"") preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                                           NSLog(@"Cancel action");
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                UITextField *textInput = alert.textFields.firstObject;
                //Save in database and show high scores
                if(![[DatabaseHelper sharedInstance] saveHighScoreWithPlayerName:textInput.text score:self.numberOfAnswers time:self.secondsSpent]){
                    //TODO ALERT THE USER
                }
                else{
                    //Push High Scores
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    HighScoresViewController *dest = [storyboard instantiateViewControllerWithIdentifier:@"highScoresId"];
                    [self.navigationController pushViewController:dest animated:YES];
                }
            }];
        
        okAction.enabled = NO;
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"gameSummaryNameLabel", @"");
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.keyboardType = UIKeyboardTypeAlphabet;
            [textField addTarget:self action:@selector(alertTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark actions
- (IBAction)playAgainTouchedUpInside:(id)sender {
    [self performSegueWithIdentifier:@"unwindToGame" sender:self];
}


#pragma mark private methods
//Returns yes if this score is an high score
-(BOOL)isAnHighScore{
    NSArray * highScores = [[DatabaseHelper sharedInstance] getHighScores];
    if(highScores.count < NUMBER_OF_HIGHSCORES){
        return YES;
    }
    HighScore * lowHighScore = highScores[0];
    NSLog(@"lowHighScore=%d %@",[lowHighScore.score intValue],lowHighScore.playerName);
    if((int)self.numberOfAnswers > [lowHighScore.score intValue]){
        return YES;
    }
    return NO;
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        UITextField *textfield =  [alertView textFieldAtIndex: 0];
        if(textfield.text.length > 0){
            if(![[DatabaseHelper sharedInstance] saveHighScoreWithPlayerName:textfield.text score:self.numberOfAnswers time:self.secondsSpent]){
                //TODO ALERT THE USER
            }
            else{
                //Push High Scores
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                HighScoresViewController *dest = [storyboard instantiateViewControllerWithIdentifier:@"highScoresId"];
                [self.navigationController pushViewController:dest animated:YES];
            }
        }
    }
}

#pragma mark UITextField in AlertController
- (void)alertTextFieldDidChange:(UITextField *)sender{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController){
        UITextField *textfield = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = textfield.text.length > 1;
    }
}
@end

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

@interface GameSummaryViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeSpentLabel;
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAnswersLabel;
@end

@implementation GameSummaryViewController

#pragma mark view life cycle methods
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
    [self.homeButton setTitle:NSLocalizedString(@"gameSummaryHomeButton", @"") forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([[DatabaseHelper sharedInstance] isAnHighScoreForScore:self.numberOfAnswers time:(NSInteger)self.secondsSpent]){
        
        //Show alert to get the name
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"gameSummaryNameAlertTitle", @"") message:NSLocalizedString(@"gameSummaryNameAlertMessage", @"") preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok action") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                UITextField *textInput = alert.textFields.firstObject;
            
            BOOL lastIsDeleted = [[DatabaseHelper sharedInstance] deleteLastHighScoreIfNeeded];
            BOOL saved = [[DatabaseHelper sharedInstance] saveHighScoreWithPlayerName:textInput.text score:self.numberOfAnswers time:self.secondsSpent];
            
            //Save in database and show high scores
            if(!(lastIsDeleted && saved)){
                //Alert the user
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"gameSummaryNameAlertErrorMessage", @"") preferredStyle:UIAlertControllerStyleAlert];
                    
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                    }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
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
            textField.delegate = self;
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
- (IBAction)homeTouchedUpInside:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
- (BOOL)textField: (UITextField *)theTextField shouldChangeCharactersInRange: (NSRange)range replacementString: (NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > theTextField.text.length){
        return NO;
    }
    
    NSUInteger newLength = [theTextField.text length] + [string length] - range.length;
    //Limit the text length to 10 caracters
    
    return newLength <= 10;
}

@end

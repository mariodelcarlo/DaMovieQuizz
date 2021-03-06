//
//  HomeViewController.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 07/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "HomeViewController.h"
#import "DatabaseHelper.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *highScoresButton;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    //Set texts
    [self.titleLabel setText:NSLocalizedString(@"homeViewContollerTitleLabel", @"")];
    [self.playButton setTitle:NSLocalizedString(@"homeViewContollerPlayButton", @"") forState:UIControlStateNormal];
    [self.highScoresButton setTitle:NSLocalizedString(@"homeViewContollerHighScoresButton", @"") forState:UIControlStateNormal];
    
    NSArray * highScores = [[DatabaseHelper sharedInstance]getHighScores];
    if([highScores count] == 0){
        self.highScoresButton.enabled = NO;
    }
    else{
        self.highScoresButton.enabled = YES;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

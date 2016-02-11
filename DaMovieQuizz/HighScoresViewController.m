//
//  HighScoresViewController.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 10/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "HighScoresViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "HighScoreTableViewCell.h"
#import "HighScore.h"
#import "Utils.h"

@interface HighScoresViewController () <NSFetchedResultsControllerDelegate>
@property(nonatomic,retain) NSFetchedResultsController *fetchedResultsController;
@end

@implementation HighScoresViewController

#pragma mark view life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the NSFetchedResultsController
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"HighScore"];
    // Edit the entity name as appropriate.
    NSManagedObjectContext *context = [(AppDelegate*)[[UIApplication sharedApplication]delegate] managedObjectContext];
    NSSortDescriptor *sortDescriptorScore = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSSortDescriptor *sortDescriptorTime = [[NSSortDescriptor alloc] initWithKey:@"timeInSeconds" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptorScore,sortDescriptorTime]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        //Show error
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"highScoresAlertMessage", @"") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Ok action") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        }];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark private methods
- (void)configureCell:(HighScoreTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell
    HighScore *highScore = (HighScore *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.nameLabel.text = highScore.playerName;
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d",[highScore.score intValue]];
    cell.timeLabel.text = [Utils getTimeStringFromSeconds:[highScore.timeInSeconds intValue]];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"HighScoreCell";
    HighScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"HighScoreCell";
    //TODO Localiser
    HighScoreTableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    headerView.nameLabel.text = NSLocalizedString(@"highScoresHeaderPlayer", @"");
    headerView.scoreLabel.text= NSLocalizedString(@"highScoresHeaderScore", @"");
    headerView.timeLabel.text = NSLocalizedString(@"highScoresHeaderTime", @"");
    
    return headerView;
}

#pragma mark actions
- (IBAction)okTouchedUpInside:(id)sender {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}
@end

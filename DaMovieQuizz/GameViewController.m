//
//  GameViewController.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "GameViewController.h"
#import "TMDBDownloaderOperation.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "DatabaseHelper.h"

@interface GameViewController () <TMDBDownloaderDelegate>
@property(nonatomic, retain) NSOperationQueue *tmdbQueue;
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingActivity;
@property (nonatomic, assign)BOOL isDownloading;

@end

@implementation GameViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.isDownloading = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    //Start download if there is no actor in database
    if([[[DatabaseHelper sharedInstance] getActors] count] == 0){
        NSLog(@"START DOWNLOADING");
        self.tmdbQueue = [[NSOperationQueue alloc] init];
        TMDBDownloaderOperation * downloadOp = [[TMDBDownloaderOperation alloc] init];
        downloadOp.delegate =  self;
        [self.tmdbQueue addOperation:downloadOp];
        self.isDownloading = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self hideWaitingUIElements:!self.isDownloading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MDBDownloaderDelegate
- (void)didFailedTMDBDownloadWithError:(NSError *)error{
    //TODO
}
    
- (void)didFinishDownloading{
    NSLog(@"NB ACTORS=%d",[[[DatabaseHelper sharedInstance] getActors] count]);
    self.isDownloading = NO;
    [self hideWaitingUIElements:YES];
}

#pragma mark NSManagedObjectContext notification
-(void)contextDidSave:(NSNotification *)notification{
    NSManagedObjectContext * sender = notification.object;
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext  * currentContext = appDelegate.managedObjectContext;
    if (sender != currentContext){
        [currentContext performBlock:^{
            [currentContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark utils
//Hide or display the UI Elements about waiting the download of elements in database
- (void)hideWaitingUIElements:(BOOL)mustHide{
    if(mustHide){
        [self.waitingActivity stopAnimating];
        self.waitingActivity.alpha = 0;
        self.waitingLabel.alpha = 0;
    }
    else{
        [self.waitingActivity startAnimating];
        self.waitingActivity.alpha = 1;
        self.waitingLabel.alpha = 1;
        [self.waitingLabel setText:NSLocalizedString(@"gameViewControllerWaitingLabel", @"")];
    }
}
@end

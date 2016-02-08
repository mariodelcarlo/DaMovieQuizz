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

@interface GameViewController () <TMDBDownloaderDelegate>
@property(nonatomic, retain) NSOperationQueue *tmdbQueue;
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *waitingActivity;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    //Start download
    self.tmdbQueue = [[NSOperationQueue alloc] init];
    TMDBDownloaderOperation * downloadOp = [[TMDBDownloaderOperation alloc] init];
    downloadOp.delegate =  self;
    [self.tmdbQueue addOperation:downloadOp];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.waitingActivity startAnimating];
    [self.waitingLabel setText:NSLocalizedString(@"gameViewControllerWaitingLabel", @"")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MDBDownloaderDelegate
- (void)didFailedTMDBDownloadWithError:(NSError *)error{
    
}
    
- (void)didFinishDownloading{
    NSLog(@"didFinishDownloading");
    //TO REMOVE
    [self listActors];
    [self.waitingActivity stopAnimating];
    self.waitingLabel.alpha = 0;
}


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

//Temporary to remove
-(void)listActors{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Actor" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    NSUInteger nbActors = [objects count];
    
    NSLog(@"NB ACTORS + %d",nbActors);
}
@end

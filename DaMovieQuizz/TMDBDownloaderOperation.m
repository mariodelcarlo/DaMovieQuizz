//
//  TMDBDownloaderOperation.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "TMDBDownloaderOperation.h"
#import <CoreData/CoreData.h>
#import "Appdelegate.h"
#import "Actor.h"
#import "Movie.h"
#import "Constants.h"

#define NB_PAGES_TO_DOWNLOAD 2

@implementation TMDBDownloaderOperation

-(id) init{
    if (![super init]) return nil;
    self.currentDownloadFailed = NO;
    self.numberOfDownloadedPages = 0;
    return self;
}

- (void)main {
    //Init managed object context
    self.threadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.threadContext.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    
    //Load Configuration
    [self loadConfigurationForImages];
    
    //Get actors
    [self downloadPopularActors];
}

//Get base url for images
- (void)loadConfigurationForImages{
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {
        if (!error){
            NSString * imagesBaseUrlString = response[@"images"][@"base_url"];
            [[NSUserDefaults standardUserDefaults] setValue:imagesBaseUrlString forKey:USER_DEFAULTS_IMAGE_URL_KEY];
        }
        else{
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailedTMDBLoadConfiguration)]){
                [self.delegate didFailedTMDBLoadConfiguration];
            }
        }
    }];
}

//Get the popular actors for the page set in parameters
-(void)downloadPopularActorForPage:(int)page withCompletion:(void (^)(BOOL success, NSError * saveError))completionBlock {
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonPopular withParameters:@{@"page":[NSNumber numberWithInt:page]} andResponseBlock:^(id response, NSError *error) {
        
        if (!error){
            NSArray * actors = response[@"results"];
            if(actors != nil){
                for(int i=0; i<actors.count;i++){
                    //check if the actor already exists
                    NSFetchRequest * requestActor = [[NSFetchRequest alloc] initWithEntityName:@"Actor"];
                    NSPredicate * actorPredicate = [NSPredicate predicateWithFormat:@"tmdbId == %d",[actors[i][@"id"] intValue]];
                    [requestActor setPredicate:actorPredicate];
                    NSError *actorError = nil;
                    NSArray *actorObjects = [self.threadContext executeFetchRequest:requestActor error:&actorError];
                    if([actorObjects count] == 0){
                        //Insert in database
                        Actor * newActor = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:self.threadContext];
                        newActor.tmdbId = [actors[i][@"id"] intValue];
                        newActor.name = actors[i][@"name"];
                    }
                }
                //save
                NSError * saveError = nil;
                if(![self.threadContext save:&saveError]){
                    if (completionBlock != nil) completionBlock(NO, saveError);
                }
                else{
                    if (completionBlock != nil) completionBlock(YES, nil);
                }
            }
            else{
                if (completionBlock != nil) completionBlock(YES, nil);
            }
        }
        else{
            if (completionBlock != nil) completionBlock(NO, error);
        }
    }];
}

//Method called when all the popular actors are saved in database for the page set in parameter
-(void)didFinishDownloadForPage:(int)page withError:(NSError *)error{
    if(error != nil){
        self.currentDownloadFailed = YES;
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailedTMDBDownloadWithError:forPage:)]){
            [self.delegate didFailedTMDBDownloadWithError:error forPage:page];
        }
    }
    self.numberOfDownloadedPages = self.numberOfDownloadedPages + 1;
    
    //If we downloaded all pages, we can send a noification to the delegate
    if(self.numberOfDownloadedPages == NB_PAGES_TO_DOWNLOAD){
        if(!self.currentDownloadFailed){
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFinishDownloading)]){
                [self.delegate didFinishDownloading];
            }
        }
    }
}

//Download NB_PAGES_TO_DOWNLOAD pages of poupular actors
-(void)downloadPopularActors{
    __weak TMDBDownloaderOperation *weakSelf = self;
    for(int page=1; page<=NB_PAGES_TO_DOWNLOAD;page++){
        [self downloadPopularActorForPage:page withCompletion:^(BOOL success, NSError *saveError) {
            [weakSelf didFinishDownloadForPage:page withError:saveError];
        }];
    }
}
@end

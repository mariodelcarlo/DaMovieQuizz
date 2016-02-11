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
                        
                        NSArray *knownFor = actors[i][@"known_for"];
                        for(int j=0; j<knownFor.count;j++){
                            //Check if the movie already exists
                            NSFetchRequest * requestMovie = [[NSFetchRequest alloc] initWithEntityName:@"Movie"];
                            NSPredicate * moviePredicate = [NSPredicate predicateWithFormat:@"tmdbId == %d",[knownFor[j][@"id"] intValue]];
                            [requestMovie setPredicate:moviePredicate];
                            NSError *movieError;
                            NSArray *objects = [self.threadContext executeFetchRequest:requestMovie error:&movieError];
                            if([objects count] == 0){
                                //Check if it's a movie and if title is not nil
                                if(knownFor[j][@"title"]!=nil && [knownFor[j][@"media_type"] isEqualToString:@"movie"]){
                                    Movie * newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:self.threadContext];
                                    newMovie.tmdbId = [knownFor[j][@"id"] intValue];
                                    newMovie.title = knownFor[j][@"title"];
                                    newMovie.mediaType = knownFor[j][@"media_type"];
                                    newMovie.posterPath = knownFor[j][@"poster_path"];
                                    [newActor addMoviesObject:newMovie];
                                }
                            }
                            else if ([objects count] == 1){
                                Movie * newMovie = objects[0];
                                [newActor addMoviesObject:newMovie];
                            }
                            else{
                                NSLog(@"Database integrity problem, skip");
                            }
                        }
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

-(void)downloadPopularActors{
    __weak TMDBDownloaderOperation *weakSelf = self;
    for(int page=1; page<=NB_PAGES_TO_DOWNLOAD;page++){
        [self downloadPopularActorForPage:page withCompletion:^(BOOL success, NSError *saveError) {
            [weakSelf didFinishDownloadForPage:page withError:saveError];
        }];
    }
}
@end

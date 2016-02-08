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
    
    //Get many pages
    for(int page=1; page<=NB_PAGES_TO_DOWNLOAD;page++)
    {
        NSLog(@"page=%d",page);
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonPopular withParameters:@{@"page":[NSNumber numberWithInt:page]} andResponseBlock:^(id response, NSError *error) {
            NSLog(@"RESPONSE BLOCK FOR PAGE %d",page);
            if (!error){
                NSArray * actors = response[@"results"];
                
                if(actors != nil){
                    for(int i=0; i<actors.count;i++){
                        
                        Actor * newActor = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:self.threadContext];
                        newActor.tmdbId = [actors[i][@"id"] intValue];
                        newActor.name = actors[i][@"name"];
                        
                        NSArray *knownFor = actors[i][@"known_for"];
                        for(int j=0; j<knownFor.count;j++)
                        {
                            //Check if the movie already exists
                            NSFetchRequest * requestMovie = [[NSFetchRequest alloc] initWithEntityName:@"Movie"];
                            NSPredicate * moviePredicate = [NSPredicate predicateWithFormat:@"tmdbId == %d",[knownFor[j][@"id"] intValue]];
                            [requestMovie setPredicate:moviePredicate];
                            NSError *movieError;
                            NSArray *objects = [self.threadContext executeFetchRequest:requestMovie error:&movieError];
                            if([objects count] == 0){
                                Movie * newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:self.threadContext];
                                newMovie.tmdbId = [knownFor[j][@"id"] intValue];
                                newMovie.title = knownFor[j][@"title"];
                                newMovie.mediaType = knownFor[j][@"media_type"];
                                newMovie.posterPath = knownFor[j][@"poster_path"];
                                [newActor addMoviesObject:newMovie];
                            }
                            else if ([objects count] == 1){
                                Movie * newMovie = objects[0];
                                [newActor addMoviesObject:newMovie];
                            }
                            else{
                                //TODO
                                NSLog(@"Integrity problem in Database");
                            }
                        }
                    }
                    //save
                    if (self.threadContext.hasChanges){
                        NSError * saveError = nil;
                        [self.threadContext save:&saveError];
                        if(saveError!=nil){
                            [self didFinishDownloadForPage:page withError:saveError];
                        }
                        else{
                            [self didFinishDownloadForPage:page withError:nil];
                        }
                    }
                    else{
                        [self didFinishDownloadForPage:page withError:nil];
                    }
                }
                else{
                    [self didFinishDownloadForPage:page withError:error];
                }
            }
            else{
                [self didFinishDownloadForPage:page withError:error];
            }
        }];
    }
}

-(void)didFinishDownloadForPage:(int)page withError:(NSError *)error{
    NSLog(@"didFinishDownloadForPage %d error=%@",page,error);
    if(error != nil){
        self.currentDownloadFailed = YES;
    }
    
    self.numberOfDownloadedPages = self.numberOfDownloadedPages + 1;
    
    //If we downloaded all pages, we can send a noification to the delegate
    if(self.numberOfDownloadedPages == NB_PAGES_TO_DOWNLOAD){
        if(self.currentDownloadFailed){
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailedTMDBDownloadWithError:)]){
                [self.delegate didFailedTMDBDownloadWithError:error];
            }

        }
        else{
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailedTMDBDownloadWithError:)]){
                [self.delegate didFinishDownloading];
            }
        }
    }
}

@end

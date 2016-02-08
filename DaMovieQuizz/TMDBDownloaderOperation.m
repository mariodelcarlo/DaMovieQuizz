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


@implementation TMDBDownloaderOperation

-(id) init{
    if (![super init]) return nil;
    return self;
}

- (void)main {
    //Init managed object context
    self.threadContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.threadContext.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    
    //Start dowloading
    [self fetchAllFamousActors:^(NSArray *actors)
     {
         for(int i=0; i<actors.count;i++){
             Actor * newActor = [NSEntityDescription insertNewObjectForEntityForName:@"Actor" inManagedObjectContext:self.threadContext];
             newActor.tmdbId = [actors[i][@"id"] intValue];
             newActor.name = actors[i][@"name"];
             //NSLog(@"--%@ %@",actors[i][@"name"],actors[i][@"id"]);
             
             NSArray *knownFor = actors[i][@"known_for"];
             for(int j=0; j<knownFor.count;j++){
                 Movie * newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:self.threadContext];
                 newMovie.tmdbId = [knownFor[j][@"id"] intValue];
                 newMovie.title = knownFor[j][@"title"];
                 newMovie.mediaType = knownFor[j][@"media_type"];
                 newMovie.posterPath = knownFor[j][@"poster_path"];
                 [newActor addMoviesObject:newMovie];
                 //NSLog(@"**%@-%@",knownFor[j][@"id"], knownFor[j][@"title"]);
             }
         }
         //save
         if (self.threadContext.hasChanges){
             NSError * error = nil;
             [self.threadContext save:&error];
         }
     }
     ];
}


- (void)fetchFamousActors:(void (^)(NSArray *actors))callback forPage:(int)page{
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonPopular withParameters:@{@"page":[NSNumber numberWithInt:page]} andResponseBlock:^(id response, NSError *error) {
        if (!error){
            NSArray * actors = response[@"results"];
            //NSLog(@"%@",actors);
            if(actors != nil){
                callback(actors);
                if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailedTMDBDownloadWithError:)]){
                    [self.delegate didFinishDownloading];
                }
            }
            else{
                if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailedTMDBDownloadWithError:)]){
                    [self.delegate didFailedTMDBDownloadWithError:error];
                }
            }
        }
        else{
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(didFailedTMDBDownloadWithError:)]){
                [self.delegate didFailedTMDBDownloadWithError:error];
            }
        }
    }];
    
}

- (void)fetchAllFamousActors:(void (^)(NSArray *pods))callback{
    for(int i=1; i<=2;i++){
        [self fetchFamousActors:callback forPage:i];
    }
}

@end

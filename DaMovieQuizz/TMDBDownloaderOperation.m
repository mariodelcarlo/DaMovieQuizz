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
             
             NSLog(@"%@-%@",actors[i][@"id"], actors[i][@"name"]);
             NSArray *films = actors[i][@"known_for"];
             for(int j=0; j<films.count;j++){
                 NSLog(@"**-%@-%@",films[j][@"id"], films[j][@"title"]);
             }
             
             //save
             if (self.threadContext.hasChanges){
                 NSError * error = nil;
                 [self.threadContext save:&error];
             }
         }
     }
     ];
}


- (void)fetchFamousActors:(void (^)(NSArray *actors))callback forPage:(int)page{
    NSLog(@"fetchFamousActors page=%d",page);
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonPopular withParameters:@{@"page":[NSNumber numberWithInt:page]} andResponseBlock:^(id response, NSError *error) {
        if (!error){
            NSArray * actors = response[@"results"];
            if(actors != nil){
                NSLog(@"ACTORS %d",[actors count]);
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

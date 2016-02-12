//
//  GameStep.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "GameStep.h"
#import "Actor.h"
#import "DatabaseHelper.h"
#import "AppDelegate.h"
#import "Utils.h"

@implementation GameStep

//Choose 2 actors randomly in database et start the download of the films in which they have played
-(void)initGameStep{
    self. numberOfActorFilmsDownloaded = 0;
    
    //We find a random famous actor
    self.randomActor1 = [[DatabaseHelper sharedInstance] getRandomActor];
        
    //We find an other random famous actor
    Actor * randomActor2 = [[DatabaseHelper sharedInstance] getRandomActor];
    
    while(self.randomActor1.tmdbId == randomActor2.tmdbId){
        randomActor2 = [[DatabaseHelper sharedInstance] getRandomActor];
    }
    self.randomActor2 = randomActor2;
    
    if([self.randomActor1.movies count] > 0 && [self.randomActor2.movies count] > 0){
        //No need to download films for randomActor1 and randomActor2
        [self createGameStep];
    }
    else{
        //Get films in which randomActor1 hasPlayed
        if([self.randomActor1.movies count] == 0){
            NSString * actorId = [NSString stringWithFormat:@"%lld",self.randomActor1.tmdbId];
            [self downloadFilmsForActorWithID:actorId withCompletion:^(BOOL success, NSError *saveError) {
                [self didFinishDownloadFilmsForActor:[actorId intValue] withError:saveError];
            }];
        }
        else{
            //No need to download films for randomActor1
            self.numberOfActorFilmsDownloaded = self.numberOfActorFilmsDownloaded + 1;
        }
        
        //Get films in which randomActorZ hasPlayed
        if([self.randomActor2.movies count] == 0){
            NSString * actorId2 = [NSString stringWithFormat:@"%lld",self.randomActor2.tmdbId];
            [self downloadFilmsForActorWithID:[NSString stringWithFormat:@"%lld",self.randomActor2.tmdbId] withCompletion:^(BOOL success, NSError *saveError) {
                [self didFinishDownloadFilmsForActor:[actorId2 intValue] withError:saveError];
            }];
        }
        else{
            //No need to download films for randomActor2
            self.numberOfActorFilmsDownloaded = self.numberOfActorFilmsDownloaded + 1;
        }
    }
}

//Callback called when all the films of the actorId passed in parameters are done
-(void)didFinishDownloadFilmsForActor:(int64_t)actorId withError:(NSError *)error{
    self.numberOfActorFilmsDownloaded = self. numberOfActorFilmsDownloaded + 1;
    if(error != nil){
        //TODO
        NSLog(@"ERROR TO HANDLE");
    }
    else{
        if(self. numberOfActorFilmsDownloaded == 2){
            [self createGameStep];
        }
    }
}

//Method called when all films/actors are saved in database
//Choose the movie and film that will be displayed as a question
//Sent a notification with these elements, to be catched by gameLogic
-(void)createGameStep{
    //Choose an actor between these two
    Actor * choosenActor = nil;
    int randomNumber = (int)[Utils randomNumberBetween:0 maxNumber:1];
    if(randomNumber == 0){
        choosenActor = self.randomActor1;
    }
    else{
        choosenActor = self.randomActor2;
    }
    
    //Choose a movie in which choosenActor has played
    Movie * movieWithActor = [[DatabaseHelper sharedInstance]getRandomMovieForActor:choosenActor];
    
    //Choose a movie in which choosenActor has notplayed
    Movie * movieWithoutActor = [[DatabaseHelper sharedInstance]getRandomMovieWithoutActor:choosenActor];
    
    //Choose a random movie between these 2
    Movie * choosenMovie = nil;
    BOOL hasPlayed = NO;
    int randomNumber2 = (int)[Utils randomNumberBetween:0 maxNumber:1];
    if(randomNumber2 == 0){
        choosenMovie = movieWithActor;
        hasPlayed = YES;
    }
    else{
        choosenMovie = movieWithoutActor;
        hasPlayed = NO;
    }
    
    self.movieTitle = choosenMovie.title;
    self.actorName = choosenActor.name;
    self.posterPath = choosenMovie.posterPath;
    self.rightAnswer = hasPlayed;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GAME_STEP_READY" object:self];
}

//Helper method, lauch the correct API request to download films for the actorId passed in parameters
//and save the movie and the link movie-actor in database
-(void)downloadFilmsForActorWithID:(NSString*)theID withCompletion:(void (^)(BOOL success, NSError * saveError))completionBlock{
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonCredits withParameters:@{@"id":theID} andResponseBlock:^(id response, NSError *error) {
        if(error){
            if (completionBlock != nil) completionBlock(NO, error);
        }
        else{
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            
            //Find the actor
            Actor * currentActor = nil;
            NSFetchRequest * requestActor = [[NSFetchRequest alloc] initWithEntityName:@"Actor"];
            NSPredicate * actorPredicate = [NSPredicate predicateWithFormat:@"tmdbId == %d",[theID intValue]];
            [requestActor setPredicate:actorPredicate];
            NSError *actorError = nil;
            NSArray *objects = [context executeFetchRequest:requestActor error:&actorError];
            if(actorError == nil && [objects count] == 1){
                currentActor = objects[0];
                
                //Parse movies
                NSDictionary * responseDict  = response;
                NSArray * movies = [responseDict objectForKey:@"cast"];
                for(NSDictionary * movieDico in movies){
                    //Don't get movie with poster_path nil
                    NSString * posterPath = [movieDico objectForKey:@"poster_path"];
                    if(posterPath != nil && posterPath != [NSNull null] && ![posterPath isEqualToString:@""]){
                        Movie * newMovie = [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:context];
                        newMovie.tmdbId = [[movieDico objectForKey:@"id"] intValue];
                        newMovie.title = [movieDico objectForKey:@"title"];
                        newMovie.mediaType = @"movie";
                        newMovie.posterPath = [movieDico objectForKey:@"poster_path"];
                        [currentActor addMoviesObject:newMovie];
                    }
                }
                
                NSError * saveError = nil;
                if(![context save:&saveError]){
                    if (completionBlock != nil) completionBlock(NO, saveError);
                }
                else{
                    if (completionBlock != nil) completionBlock(YES, nil);
                }
            }
            else{
                //Actor not found, to improve
                if (completionBlock != nil) completionBlock(NO, [NSError errorWithDomain:@"Actor Error" code:144 userInfo:nil]);
            }
        }
    }];
}
@end

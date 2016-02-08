//
//  DatabaseHelper.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "DatabaseHelper.h"
#import "AppDelegate.h"


@implementation DatabaseHelper

//Singleton
+ (id)sharedInstance {
    static DatabaseHelper *databaseHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseHelper = [[DatabaseHelper alloc] init];
    });
    return databaseHelper;
}

//Returns an array of Actors
- (NSArray *)getActors{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Actor" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    /*for(int i=0; i<objects.count;i++){
        Actor * actor = objects[i];
        NSLog(@"------ACTEUR->%@ %lld",actor.name,actor.tmdbId);
        
        NSSet * movies = actor.movies;
        for(Movie * movie in movies){
            NSLog(@"MOVIE->%@ %lld",movie.title, movie.tmdbId);
        }
    }
    */
    return objects;
}

//Returns an array of Movies
- (NSArray *)getMovies{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    /*
    for(int i=0; i<objects.count;i++){
        Movie * movie = objects[i];
        NSLog(@"------Movie->%@ %lld",movie.title,movie.tmdbId);
        
        NSSet * actors = movie.actors;
        for(Actor * actor in actors){
            NSLog(@"ACTOR->%@ %lld",actor.name, actor.tmdbId);
        }
    }
     */
    
    return objects;
}

//Generate a random number between 2 bounds, bounds are included
- (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max{
    //arc4random_uniform returns value between 0 and the bounds set in parameter
    return min + arc4random_uniform((int)max - (int)min + 1);
}

-(Actor *)getRandomActor{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *myRequest = [[NSFetchRequest alloc] init];
    [myRequest setEntity: [NSEntityDescription entityForName:@"Actor" inManagedObjectContext:context]];
    
    NSError *error = nil;
    NSUInteger myEntityCount = [context countForFetchRequest:myRequest error:&error];
    
    NSUInteger offset = [self randomNumberBetween:0 maxNumber:myEntityCount-1];
    [myRequest setFetchOffset:offset];
    [myRequest setFetchLimit:1];
    
    NSArray* objects = [context executeFetchRequest:myRequest error:&error];
    id randomObject = [objects objectAtIndex:0];
    
    return (Actor*)randomObject;
}

@end

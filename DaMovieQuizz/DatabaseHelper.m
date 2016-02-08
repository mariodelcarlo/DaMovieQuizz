//
//  DatabaseHelper.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "DatabaseHelper.h"
#import "AppDelegate.h"
#import "Actor.h"
#import "Movie.h"

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

@end

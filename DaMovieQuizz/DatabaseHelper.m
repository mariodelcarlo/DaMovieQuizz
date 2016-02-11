//
//  DatabaseHelper.m
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import "DatabaseHelper.h"
#import "AppDelegate.h"
#import "HighScore.h"
#import "Constants.h"

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
    //TODO Handle error
    
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
    //TODO Handle error
    
    return objects;
}

//Generate a random number between 2 bounds, bounds are included
- (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max{
    //arc4random_uniform returns value between 0 and the bounds set in parameter
    return min + arc4random_uniform((int)max - (int)min + 1);
}

//Get a random Actor in database
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

//Get a random Movie for an actor in database
-(Movie*)getRandomMovieForActor:(Actor *)actor{
    NSArray * movies = [actor.movies allObjects];
    NSUInteger offset = [self randomNumberBetween:0 maxNumber:movies.count-1];
    Movie *randomMovie = movies[offset];
    return randomMovie;
}

//Get a random movie in database where the actor given in parameter has not played
-(Movie*)getRandomMovieWithoutActor:(Actor *)actor{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *myRequest = [[NSFetchRequest alloc] init];
    [myRequest setEntity: [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE actors.name CONTAINS[cd] %@",actor.name];
    [myRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:myRequest error:&error];
    if(error == nil){
        NSUInteger offset = [self randomNumberBetween:0 maxNumber:objects.count-1];
        Movie *randomMovie = objects[offset];
        return randomMovie;
    }
    return nil;
}

//Returns an array of HighScores, sorted by higher score and then lower time
- (NSArray *)getHighScores{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"HighScore" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDesc];
    NSSortDescriptor *sortDescriptorScore = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSSortDescriptor *sortDescriptorTime = [[NSSortDescriptor alloc] initWithKey:@"timeInSeconds" ascending:YES];
    [request setSortDescriptors:@[sortDescriptorScore,sortDescriptorTime]];
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    return objects;
}

//Save an HighScore and returns TRUE if the HighScore is saved and FALSE if it's not
-(BOOL)saveHighScoreWithPlayerName:(NSString*)thePlayerName score:(NSInteger)theScore time:(NSInteger)theTime{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    HighScore * newHighScore = [NSEntityDescription insertNewObjectForEntityForName:@"HighScore" inManagedObjectContext:context];
    newHighScore.playerName = thePlayerName;
    newHighScore.score = [NSNumber numberWithInteger:theScore];
    newHighScore.timeInSeconds = [NSNumber numberWithInteger:theTime];
    
    NSError * saveError = nil;
    [context save:&saveError];
    if(saveError!=nil){
        NSLog(@"Highscore NOT saved");
        return NO;
    }
    return YES;
}

//Returns yes if this score is an high score
-(BOOL)isAnHighScoreForScore:(NSInteger)theScore time:(NSInteger)theTime{
    NSArray * highScores = [[DatabaseHelper sharedInstance] getHighScores];
    if(highScores.count == 0){
        return YES;
    }
    int lastIndex = highScores.count -1;
    HighScore * lowHighScore = highScores[lastIndex];
    NSLog(@"isAnHighScoreForScore:%d time=%d",theScore, theTime);
    NSLog(@"lowHighScore=%d %@ %d",[lowHighScore.score intValue],lowHighScore.playerName, [lowHighScore.timeInSeconds intValue]);
    if((int)theScore > [lowHighScore.score intValue]){
        return YES;
    }
    else if((int)theScore == [lowHighScore.score intValue] && theTime < [lowHighScore.timeInSeconds intValue]){
        return YES;
    }
    return NO;
}
@end

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
    
    return objects;
}


@end

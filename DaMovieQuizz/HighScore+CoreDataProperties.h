//
//  HighScore+CoreDataProperties.h
//  
//
//  Created by Del Carlo Marie-Odile on 10/02/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HighScore.h"

NS_ASSUME_NONNULL_BEGIN

@interface HighScore (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *playerName;
@property (nullable, nonatomic, retain) NSNumber *score;
@property (nullable, nonatomic, retain) NSNumber *timeInSeconds;

@end

NS_ASSUME_NONNULL_END

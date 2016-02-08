//
//  Movie+CoreDataProperties.h
//  
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@interface Movie (CoreDataProperties)

@property (nonatomic) int64_t tmdbId;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *mediaType;
@property (nullable, nonatomic, retain) NSString *posterPath;
@property (nullable, nonatomic, retain) NSSet<Actor *> *actors;

@end

@interface Movie (CoreDataGeneratedAccessors)

- (void)addActorsObject:(Actor *)value;
- (void)removeActorsObject:(Actor *)value;
- (void)addActors:(NSSet<Actor *> *)values;
- (void)removeActors:(NSSet<Actor *> *)values;

@end

NS_ASSUME_NONNULL_END

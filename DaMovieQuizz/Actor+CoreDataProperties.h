//
//  Actor+CoreDataProperties.h
//  
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Actor.h"

NS_ASSUME_NONNULL_BEGIN

@interface Actor (CoreDataProperties)

@property (nonatomic) int64_t tmdbId;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Movie *> *movies;

@end

@interface Actor (CoreDataGeneratedAccessors)

- (void)addMoviesObject:(Movie *)value;
- (void)removeMoviesObject:(Movie *)value;
- (void)addMovies:(NSSet<Movie *> *)values;
- (void)removeMovies:(NSSet<Movie *> *)values;

@end

NS_ASSUME_NONNULL_END

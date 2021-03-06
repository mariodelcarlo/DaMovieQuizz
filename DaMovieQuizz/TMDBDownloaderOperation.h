//
//  TMDBDownloaderOperation.h
//  DaMovieQuizz
//
//  Created by Del Carlo Marie-Odile on 08/02/2016.
//  Copyright © 2016 Del Carlo Marie-Odile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JLTMDbClient.h>

@protocol TMDBDownloaderDelegate <NSObject>
- (void)didFailedTMDBDownloadWithError:(NSError *)error forPage:(int)page;
- (void)didFailedTMDBLoadConfiguration;
- (void)didFinishDownloading;
@end

@interface TMDBDownloaderOperation : NSOperation
@property(nonatomic, retain) NSManagedObjectContext * threadContext;
@property(nonatomic, assign) id<TMDBDownloaderDelegate> delegate;
@property(nonatomic,assign) BOOL currentDownloadFailed;
@property(nonatomic,assign) NSInteger numberOfDownloadedPages;
@end

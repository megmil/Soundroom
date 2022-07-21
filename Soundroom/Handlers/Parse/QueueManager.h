//
//  ParseQueueManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import <Foundation/Foundation.h>
#import "QueueSong.h"

#define QueueManagerUpdatedQueueNotification @"QueueManagerUpdatedQueueNotification"

NS_ASSUME_NONNULL_BEGIN

@interface QueueManager : NSObject

+ (instancetype)shared;

+ (void)requestSongWithSpotifyId:(NSString *)spotifyId;
+ (void)getSpotifyIdForSongWithId:(NSString *)songId completion:(PFStringResultBlock)completion;

- (void)playTopSong;

- (void)resetQueue;
- (void)fetchQueue;
- (void)updateQueueSongWithId:(NSString * _Nonnull)songId;
- (void)removeQueueSong:(QueueSong *)song;
- (void)insertQueueSong:(QueueSong *)song;
- (NSMutableArray <QueueSong *> *)queue;
- (NSMutableArray <NSNumber *> *)scores;

@end

NS_ASSUME_NONNULL_END

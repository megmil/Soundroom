//
//  QueueSong.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface QueueSong : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *spotifyId;
@property (nonatomic, strong) NSNumber *score;

+ (void)requestSongWithSpotifyId:(NSString *)spotifyId roomId:(NSString *)roomId completion:(PFBooleanResultBlock _Nullable)completion;
+ (void)getCurrentQueueSongs;
+ (void)incrementScoreForQueueSongWithId:(NSString *)queueSongId byAmount:(NSNumber *)amount;
+ (void)deleteAllQueueSongsWithRoomId:(NSString *)roomId;

- (BOOL)isUpvotedByCurrentUser;
- (BOOL)isDownvotedByCurrentUser;
- (BOOL)isNotVotedByCurrentUser;

@end

NS_ASSUME_NONNULL_END

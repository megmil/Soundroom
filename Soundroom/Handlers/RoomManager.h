//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Request.h"
#import "Song.h" // need for votestate
#import "Upvote.h"
#import "Downvote.h"

#define RoomManagerJoinedRoomNotification @"CurrentRoomManagerJoinedRoomNotification"
#define RoomManagerLeftRoomNotification @"CurrentRoomManagerLeftRoomNotification"
#define RoomManagerUpdatedQueueNotification @"RoomManagerUpdatedQueueNotification"
#define RoomManagerUpdatedCurrentSongNotification @"RoomManagerUpdatedCurrentSongNotification"

NS_ASSUME_NONNULL_BEGIN

@interface RoomManager : NSObject

@property (strong, nonatomic, readonly) NSString *currentRoomId;
@property (strong, nonatomic, readonly) NSString *currentRoomName;
@property (strong, nonatomic, readonly) NSMutableArray <Song *> *queue;
@property (strong, nonatomic) Track *currentTrack;
@property (nonatomic, readonly) BOOL isCurrentUserHost;

+ (instancetype)shared;

# pragma mark - Room Tab Methods

- (void)fetchCurrentRoomWithCompletion:(PFBooleanResultBlock)completion;
- (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;
- (void)reloadTrackData;
- (void)playTopSong;

# pragma mark - Live Query Event Handlers

- (void)joinRoomWithId:(NSString *)currentRoomId;
- (void)clearRoomData;
- (void)insertRequest:(Request *)request;
- (void)removeRequestWithId:(NSString *)requestId;
- (void)incrementScoreForRequestWithId:(NSString *)requestId amount:(NSNumber *)amount;
- (void)setCurrentTrackWithSpotifyId:(NSString *)spotifyId;

@end

NS_ASSUME_NONNULL_END

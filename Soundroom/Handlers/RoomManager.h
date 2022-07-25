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

// room data
- (NSString *)currentRoomId;
- (NSString *)currentRoomName;
- (NSString *)currentHostId;
- (NSString *)currentSongId;
- (NSMutableArray <Song *> *)queue;
- (BOOL)isInRoom;
- (BOOL)isCurrentUserHost;

+ (instancetype)shared;

- (void)fetchCurrentRoomWithCompletion:(PFBooleanResultBlock)completion;
- (void)joinRoomWithId:(NSString *)currentRoomId;
- (void)clearRoomData;

- (void)insertRequest:(Request *)request;
- (void)removeRequestWithId:(NSString *)requestId;

- (void)incrementScoreForRequestWithId:(NSString *)requestId amount:(NSNumber *)amount;
- (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;

- (void)reloadTrackData;
- (void)playTopSong;

@end

NS_ASSUME_NONNULL_END

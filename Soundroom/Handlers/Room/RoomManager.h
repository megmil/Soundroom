//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@class Request;
@class Song;
@class Upvote;
@class Downvote;
@class Track;

extern NSString *const RoomManagerJoinedRoomNotification;

@protocol RoomManagerDelegate

- (void)didInsertSongAtIndex:(NSUInteger)index;
- (void)didDeleteSongAtIndex:(NSUInteger)index;
- (void)didMoveSongAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;
- (void)didUpdateCurrentTrack;
- (void)didLoadQueue;
- (void)didLeaveRoom;
- (void)setPlayState:(PlayState)playState;
- (void)showMissingPlayerAlert;

@end

@interface RoomManager : NSObject

@property (strong, nonatomic, readonly, getter=currentRoomId) NSString *currentRoomId;
@property (strong, nonatomic, readonly, getter=currentRoomName) NSString *currentRoomName;
@property (strong, nonatomic, readonly, getter=queue) NSMutableArray <Song *> *queue;
@property (strong, nonatomic, readonly, getter=currentTrack) Track *currentTrack;
@property (strong, nonatomic, readonly, getter=currentTrackStreamingId) NSString *currentTrackStreamingId;
@property (strong, nonatomic, readonly, getter=hostId) NSString *hostId;
@property (nonatomic, readonly, getter=isCurrentUserHost) BOOL isCurrentUserHost;
@property (nonatomic, readonly, getter=listeningMode) RoomListeningMode listeningMode;
@property (nonatomic, weak) id<RoomManagerDelegate> delegate;

+ (instancetype)shared;

# pragma mark - Room VCs

- (void)fetchCurrentRoomWithCompletion:(void (^)(BOOL isInRoom))completion;
- (void)reloadTrackDataWithCompletion:(void (^)(void))completion;
- (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;
- (void)playTopSong;

# pragma mark - Music Player

- (void)updatePlayerWithPlayState:(PlayState)playState;
- (void)stopPlayback;

# pragma mark - Live Query Event Handlers

- (void)addUpvote:(Upvote *)upvote;
- (void)deleteUpvote:(Upvote *)upvote;
- (void)addDownvote:(Downvote *)downvote;
- (void)deleteDownvote:(Downvote *)downvote;
- (void)joinRoomWithId:(NSString *)currentRoomId;
- (void)clearRoomData;
- (void)insertRequest:(Request *)request;
- (void)removeRequestWithId:(NSString *)requestId;
- (void)updateCurrentTrackWithISRC:(NSString *)isrc;

@end

NS_ASSUME_NONNULL_END

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

NS_ASSUME_NONNULL_BEGIN

extern NSString *const RoomManagerJoinedRoomNotification;

@protocol RoomManagerDelegate
- (void)didInsertSongAtIndex:(NSUInteger)index;
- (void)didDeleteSongAtIndex:(NSUInteger)index;
- (void)didMoveSongAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;
- (void)didUpdateCurrentTrack;
- (void)didLoadQueue;
- (void)didLeaveRoom;
- (void)setPlayState:(PlayState)playState;
@end

@interface RoomManager : NSObject

@property (strong, nonatomic, readonly, getter=currentRoomId) NSString *currentRoomId;
@property (strong, nonatomic, readonly, getter=currentRoomName) NSString *currentRoomName;
@property (strong, nonatomic, readonly, getter=queue) NSMutableArray <Song *> *queue;
@property (strong, nonatomic, readonly, getter=currentTrack) Track *currentTrack;
@property (strong, nonatomic, readonly, getter=currentTrackSpotifyURI) NSString *currentTrackSpotifyURI;
@property (nonatomic, readonly, getter=isCurrentUserHost) BOOL isCurrentUserHost;
@property (nonatomic, weak) id<RoomManagerDelegate> delegate;

+ (instancetype)shared;

# pragma mark - Room Tab Methods

- (void)fetchCurrentRoomWithCompletion:(PFBooleanResultBlock)completion;
- (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;
- (void)reloadTrackDataWithCompletion:(PFBooleanResultBlock)completion;
- (void)playTopSong;

# pragma mark - Spotify Session Manager Methods

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
- (void)setCurrentTrackWithSpotifyId:(NSString *)spotifyId;

@end

NS_ASSUME_NONNULL_END

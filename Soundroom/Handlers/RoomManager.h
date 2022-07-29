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
- (void)insertCellAtIndex:(NSUInteger)index;
- (void)deleteCellAtIndex:(NSUInteger)index;
- (void)moveCellAtIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;
- (void)didUpdateCurrentTrack;
- (void)didLoadQueue;
- (void)didLeaveRoom;
@end

@interface RoomManager : NSObject

@property (strong, nonatomic, readonly, getter=currentRoomId) NSString *currentRoomId;
@property (strong, nonatomic, readonly, getter=currentRoomName) NSString *currentRoomName;
@property (strong, nonatomic, readonly, getter=queue) NSMutableArray <Song *> *queue;
@property (strong, nonatomic, readonly, getter=currentTrack) Track *currentTrack;
@property (nonatomic, readonly, getter=isCurrentUserHost) BOOL isCurrentUserHost;
@property (nonatomic, weak) id<RoomManagerDelegate> delegate;

+ (instancetype)shared;

# pragma mark - Room Tab Methods

- (void)fetchCurrentRoomWithCompletion:(PFBooleanResultBlock)completion;
- (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;
- (void)reloadTrackDataWithCompletion:(PFBooleanResultBlock)completion;
- (void)togglePlayback;

# pragma mark - Live Query Event Handlers

- (void)joinRoomWithId:(NSString *)currentRoomId;
- (void)clearRoomData;
- (void)insertRequest:(Request *)request;
- (void)removeRequestWithId:(NSString *)requestId;
- (void)incrementScoreForRequestWithId:(NSString *)requestId amount:(NSNumber *)amount;
- (void)setCurrentTrackWithSpotifyId:(NSString *)spotifyId;

@end

NS_ASSUME_NONNULL_END

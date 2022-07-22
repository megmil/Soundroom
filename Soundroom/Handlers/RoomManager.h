//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "QueueSong.h"

#define RoomManagerJoinedRoomNotification @"CurrentRoomManagerJoinedRoomNotification"
#define RoomManagerLeftRoomNotification @"CurrentRoomManagerLeftRoomNotification"
#define RoomManagerUpdatedQueueNotification @"RoomManagerUpdatedQueueNotification"
#define RoomManagerUpdatedCurrentSongNotification @"RoomManagerUpdatedCurrentSongNotification"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VoteState) {
    Upvoted,
    Downvoted,
    NotVoted
};

@interface RoomManager : NSObject

// room data
@property (nonatomic, strong, readonly) NSString *currentRoomId;
@property (nonatomic, strong, readonly) NSString *currentRoomName;
@property (nonatomic, strong, readonly) NSString *currentHostId;
@property (nonatomic, strong, readonly) NSString *currentSongId;
@property (nonatomic, readonly) BOOL isInRoom;
@property (nonatomic, readonly) BOOL isCurrentUserHost;

// queue data
@property (nonatomic, strong, readonly) NSMutableArray <QueueSong *> *queue;
@property (nonatomic, strong, readonly) NSMutableArray <NSNumber *> *scores;

+ (instancetype)shared;

- (void)fetchCurrentRoom;
- (void)joinRoomWithId:(NSString *)currentRoomId;
- (void)clearRoomData;

- (void)insertQueueSong:(QueueSong *)song;
- (void)removeQueueSong:(QueueSong *)song;
- (void)updateQueueSongWithId:(NSString *)songId;

- (void)getVoteStateForSongWithId:(NSString *)songId completion:(void (^)(VoteState voteState))completion;
- (void)clearLocalVoteData;

- (void)playTopSong;

@end

NS_ASSUME_NONNULL_END

//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Room.h"
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
@property (nonatomic, strong) NSString *currentRoomId;
@property (nonatomic, strong) NSString *currentRoomName;
@property (nonatomic, strong) NSString *currentHostId;
@property (nonatomic, strong) NSString *currentSongId;
@property (nonatomic) BOOL isInRoom;

// queue data
@property (nonatomic, strong) NSMutableArray <QueueSong *> *queue;
@property (nonatomic, strong) NSMutableArray <NSNumber *> *scores;

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

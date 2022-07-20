//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Room.h"
#import "QueueSong.h"

#define ParseRoomManagerJoinedRoomNotification @"ParseRoomManagerJoinedRoomNotification"
#define ParseRoomManagerLeftRoomNotification @"ParseRoomManagerLeftRoomNotification"
#define ParseRoomManagerUpdatedQueueNotification @"ParseRoomManagerUpdatedQueueNotification"

NS_ASSUME_NONNULL_BEGIN

@interface ParseRoomManager : NSObject

@property (nonatomic, strong) NSString *currentRoomId;

+ (instancetype)shared;

- (void)inviteUserWithId:(NSString *)userId;
- (void)addUserWithId:(NSString *)userId;
- (void)removeUserWithId:(NSString *)userId;
- (void)removeAllUsers;

- (void)requestSongWithSpotifyId:(NSString *)spotifyId;
- (NSMutableArray <QueueSong *> *)queue;
- (void)refreshQueue;

- (NSString *)currentRoomTitle; // TODO: properties?
- (NSString *)currentHostId;
- (void)reset; // TODO: rename

@end

NS_ASSUME_NONNULL_END

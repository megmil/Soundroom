//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Room.h"
#import "QueueSong.h"

#define CurrentRoomManagerJoinedRoomNotification @"CurrentRoomManagerJoinedRoomNotification"
#define CurrentRoomManagerLeftRoomNotification @"CurrentRoomManagerLeftRoomNotification"

NS_ASSUME_NONNULL_BEGIN

@interface RoomManager : NSObject

@property (nonatomic, strong) NSString *currentRoomId;
@property (nonatomic, strong) NSString *currentRoomName;
@property (nonatomic, strong) NSString *currentHostId;
@property (nonatomic, strong) NSString *currentSongId;

+ (instancetype)shared;

- (void)removeAllUsers;

- (void)requestSongWithSpotifyId:(NSString *)spotifyId;

- (void)joinRoomWithId:(NSString * _Nonnull)currentRoomId;
- (void)leaveCurrentRoom;

@end

NS_ASSUME_NONNULL_END

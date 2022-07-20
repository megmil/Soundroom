//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Room.h"

#define RoomManagerJoinedRoomNotification @"CurrentRoomManagerJoinedRoomNotification"
#define RoomManagerLeftRoomNotification @"CurrentRoomManagerLeftRoomNotification"

NS_ASSUME_NONNULL_BEGIN

@interface RoomManager : NSObject

@property (nonatomic, strong) NSString *currentRoomId;
@property (nonatomic, strong) NSString *currentRoomName;
@property (nonatomic, strong) NSString *currentHostId;
@property (nonatomic, strong) NSString *currentSongId;

+ (instancetype)shared;

- (void)updateRoomWithCurrentSongId:(NSString *)currentSongId;

- (void)joinRoomWithId:(NSString * _Nonnull)currentRoomId;
- (void)joinRoom:(Room * _Nonnull)room;
- (void)leaveCurrentRoom;
- (void)deleteCurrentRoom;

- (BOOL)isCurrentUserHost;

@end

NS_ASSUME_NONNULL_END

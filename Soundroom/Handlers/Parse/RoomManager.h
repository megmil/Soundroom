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
@property (nonatomic) BOOL isInRoom;

+ (instancetype)shared;

+ (void)createRoomWithTitle:(NSString *)title;

- (void)updateRoomWithCurrentSongId:(NSString *)currentSongId;

- (void)fetchCurrentRoom;

- (void)joinRoomWithId:(NSString * _Nonnull)currentRoomId;
- (void)joinRoom:(Room * _Nonnull)room;

- (void)clearRoomData;

@end

NS_ASSUME_NONNULL_END

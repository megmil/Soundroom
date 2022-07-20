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

@interface CurrentRoomManager : NSObject

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *hostId;
@property (nonatomic, strong) NSString *currentSongId;

+ (instancetype)shared;

- (void)removeAllUsers;

- (void)requestSongWithSpotifyId:(NSString *)spotifyId;
- (void)refreshQueue;
- (void)reset; // TODO: rename

@end

NS_ASSUME_NONNULL_END

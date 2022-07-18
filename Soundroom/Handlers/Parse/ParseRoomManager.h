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

- (void)inviteUserWithId:(NSString *)userId completion:(PFBooleanResultBlock _Nullable)completion;
- (void)addUserWithId:(NSString *)userId completion:(PFBooleanResultBlock _Nullable)completion;
- (void)removeUserWithId:(NSString *)userId completion:(PFBooleanResultBlock _Nullable)completion;
- (void)removeAllUsersWithCompletion:(PFBooleanResultBlock _Nullable)completion;

- (void)requestSongWithSpotifyId:(NSString *)spotifyId completion:(PFBooleanResultBlock _Nullable)completion;
- (void)updateQueueWithSong:(QueueSong *)song;
- (void)updateQueueWithSongs:(NSArray <QueueSong *> *)songs;
- (void)updateScoreForQueueSong:(QueueSong *)song;
- (NSMutableArray <QueueSong *> *)queue;

- (NSString *)currentRoomTitle; // TODO: properties?
- (NSString *)currentHostId;
- (void)reset; // TODO: rename

@end

NS_ASSUME_NONNULL_END

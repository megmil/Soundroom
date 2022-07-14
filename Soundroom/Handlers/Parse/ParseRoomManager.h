//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Room.h"

#define ParseRoomManagerJoinedRoomNotification @"ParseRoomManagerJoinedRoomNotification"
#define ParseRoomManagerLeftRoomNotification @"ParseRoomManagerLeftRoomNotification"

NS_ASSUME_NONNULL_BEGIN

@interface ParseRoomManager : NSObject

@property (nonatomic, strong) NSString *currentRoomId;

+ (instancetype)shared;

- (void)requestSongWithSpotifyId:(NSString *)spotifyId completion:(PFBooleanResultBlock _Nullable)completion;
- (void)inviteUserWithId:(NSString *)userId completion:(PFBooleanResultBlock _Nullable)completion;
- (void)removeCurrentUserWithCompletion:(PFBooleanResultBlock _Nullable)completion;
- (void)lookForCurrentRoomWithCompletion:(PFBooleanResultBlock _Nullable)completion;
- (BOOL)currentRoomExists;
- (void)resetCurrentRoomId;
- (NSString *)currentRoomTitle;

@end

NS_ASSUME_NONNULL_END

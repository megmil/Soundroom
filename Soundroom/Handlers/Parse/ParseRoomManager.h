//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Room.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseRoomManager : NSObject

+ (instancetype)shared;

// TODO: add nullable
- (void)createRoomWithTitle:(NSString *)title
                 completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion;
- (void)queueSongWithSpotifyId:(NSString *)spotifyId
                    completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion;
- (void)addCurrentUserToRoomWithId:(NSString *)roomId
                        completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion;
- (BOOL)inRoom;
- (void)inviteUserWithId:(NSString *)userId completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

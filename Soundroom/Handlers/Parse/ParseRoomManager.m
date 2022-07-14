//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseRoomManager.h"
#import "QueueSong.h"
@import ParseLiveQuery;

@implementation ParseRoomManager {
    Room *_currentRoom;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)requestSongWithSpotifyId:(NSString *)spotifyId completion:(PFBooleanResultBlock _Nullable)completion {
    if (_currentRoom) {
        [QueueSong requestSongWithSpotifyId:spotifyId roomId:self.currentRoomId completion:completion];
    }
}

- (void)inviteUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [_currentRoom addObject:userId forKey:@"memberIds"];
        [_currentRoom saveInBackgroundWithBlock:completion];
    }
}

- (BOOL)currentRoomExists {
    return _currentRoom;
}

- (void)setCurrentRoomId:(NSString *)currentRoomId {
    if (currentRoomId) {
        [Room getRoomWithId:currentRoomId completion:^(PFObject *room, NSError *error) {
            if (room) {
                self.currentRoomId = currentRoomId;
                _currentRoom = (Room *)room;
            }
        }];
    }
}

@end

//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseRoomManager.h"
#import "ParseUserManager.h"
#import "QueueSong.h"

@implementation ParseRoomManager

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)createRoomWithTitle:(NSString *)title
                 completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion {
    
    Room *newRoom = [Room new];
    newRoom.queue = [NSMutableArray array];
    newRoom.members = [NSMutableArray array];
    [newRoom.members addObject:[PFUser currentUser]];
    newRoom.title = title;
    
    [newRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self addCurrentUserToRoomWithId:newRoom.objectId completion:completion];
        } else {
            completion(succeeded, error);
        }
    }];
}

- (void)queueSongWithSpotifyId:(NSString *)spotifyId
                    completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion {
    if ([self inRoom]) {
        [QueueSong queueSongWithSpotifyId:spotifyId roomId:[self currentRoom] completion:completion];
    }
}

- (void)addCurrentUserToRoomWithId:(NSString *)roomId
                        completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setValue:roomId forKey:@"roomId"];
    [currentUser saveInBackgroundWithBlock:completion];
}

- (BOOL)inRoom {
    PFUser *currentUser = [PFUser currentUser];
    return [currentUser valueForKey:@"roomId"];
}

- (NSString *)currentRoom {
    PFUser *currentUser = [PFUser currentUser];
    return [currentUser valueForKey:@"roomId"];
}

@end

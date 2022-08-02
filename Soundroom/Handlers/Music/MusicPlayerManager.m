//
//  MusicPlayerManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "MusicPlayerManager.h"
#import "RoomManager.h"

NSString *const MusicPlayerManagerAuthorizedNotificaton = @"MusicPlayerManagerAuthorizedNotificaton";
NSString *const MusicPlayerManagerDeauthorizedNotificaton = @"MusicPlayerManagerDeauthorizedNotificaton";

@implementation MusicPlayerManager

+ (instancetype)shared {
    static MusicPlayerManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)authorizeSession {
    [_musicPlayer authorizeSessionWithCompletion:^(BOOL succeeded) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerAuthorizedNotificaton object:nil];
        }
    }];
}

- (void)signOut {
    [_musicPlayer signOutWithCompletion:^(BOOL succeeded) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerDeauthorizedNotificaton object:nil];
        }
    }];
}

- (void)resumePlayback {
    
    if (_isPlaying) {
        return;
    }
    
    NSString *roomTrackStreamingId = [[RoomManager shared] currentTrackStreamingId];
    NSString *playerTrackStreamingId = [_musicPlayer playbackTrackId];
    BOOL isMatched = roomTrackStreamingId && [roomTrackStreamingId isEqualToString:playerTrackStreamingId];
    
    if (isMatched) {
        [_musicPlayer resumePlayback];
        return;
    }
    
    if (!playerTrackStreamingId) {
        [_musicPlayer playTrackWithStreamingId:roomTrackStreamingId];
    }
    
    [[RoomManager shared] playTopSong];
    
}

- (void)setIsPlaying:(BOOL)isPlaying {
    
    if (_isPlaying == isPlaying) {
        return;
    }
    
    _isPlaying = isPlaying;
    [[RoomManager shared] updatePlayerWithPlayState:_isPlaying];
    
}

@end

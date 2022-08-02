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

# pragma mark - Authentication

- (void)authorizeSession {
    
    if (!_musicPlayer || _accessToken) {
        return;
    }
    
    [_musicPlayer authorizeSession];
}

- (void)signOut {
    if (_musicPlayer) {
        [_musicPlayer signOut];
    }
}

- (void)setAccessToken:(NSString *)accessToken {
    
    _accessToken = accessToken;
    
    if (accessToken) {
        _isSessionAuthorized = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerAuthorizedNotificaton object:nil];
        return;
    }
    
    _isSessionAuthorized = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerDeauthorizedNotificaton object:nil];
    
}

# pragma mark - Playback

- (void)playTrackWithStreamingId:(NSString *)streamingId {
    // TODO: convert spotifyId to appleMusicId if necessary
}

- (void)pausePlayback {
    if (_musicPlayer && _isPlaying) {
        [_musicPlayer pausePlayback];
    }
}

- (void)resumePlayback {
    
    if (!_musicPlayer || _isPlaying) {
        return;
    }
    
    NSString *roomTrackSpotifyId = [[RoomManager shared] currentTrackSpotifyURI];
    NSString *roomTrackAppleMusicId = [[RoomManager shared] currentTrackAppleMusicId];
    NSString *playerTrackStreamingId = [_musicPlayer playbackTrackId];
    BOOL isMatched = (roomTrackSpotifyId && [roomTrackSpotifyId isEqualToString:playerTrackStreamingId]) ||
                     (roomTrackAppleMusicId && [roomTrackAppleMusicId isEqualToString:playerTrackStreamingId]);
    
    if (isMatched) {
        [_musicPlayer resumePlayback];
        return;
    }
    
    if (!playerTrackStreamingId) {
        [_musicPlayer playTrackWithStreamingId:roomTrackStreamingId];
    }
    
    [[RoomManager shared] playTopSong];
    
}

- (void)validateNewPlayerState {
    
    NSString *roomTrackId = [[RoomManager shared] currentTrackSpotifyURI];
    
    // check if music player is playing the wrong song
    if (_isPlaying && ![roomTrackId isEqualToString:_playbackTrackId]) {
        [[RoomManager shared] stopPlayback];
        [self pausePlayback];
        return;
    }
    
    // if music player is playing the right song, resume
    if (!_isPlaying && roomTrackId) {
        [self resumePlayback];
    }
    
}

- (void)didEndCurrentSong {
    [self pausePlayback]; // TODO: confirm app remote is not connected for non-playing members
    [[RoomManager shared] playTopSong];
}

- (void)setIsPlaying:(BOOL)isPlaying {
    
    if (_isPlaying == isPlaying) {
        return;
    }
    
    _isPlaying = isPlaying;
    [[RoomManager shared] updatePlayerWithPlayState:_isPlaying];
    
}

# pragma mark - Session Manager

- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    if (_musicPlayer) {
        [_musicPlayer openURLContexts:URLContexts];
    }
}

- (void)sceneWillResignActive {
    if (_musicPlayer) {
        [_musicPlayer sceneWillResignActive];
    }
}

- (void)sceneDidBecomeActive {
    if (_musicPlayer) {
        [_musicPlayer sceneDidBecomeActive];
    }
}

@end

//
//  MusicPlayerManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "MusicPlayerManager.h"
#import "RoomManager.h"
#import "SpotifySessionManager.h"
#import "AppleMusicSessionManager.h"

NSString *const MusicPlayerManagerAuthorizedNotificaton = @"MusicPlayerManagerAuthorizedNotificaton";
NSString *const MusicPlayerManagerDeauthorizedNotificaton = @"MusicPlayerManagerDeauthorizedNotificaton";

@implementation MusicPlayerManager {
    NSString *_accessToken;
}

+ (instancetype)shared {
    static MusicPlayerManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)setStreamingService:(AccountType)streamingService {
    
    if (streamingService != Spotify && streamingService != AppleMusic) {
        return;
    }
    
    _streamingService = streamingService;
    _musicPlayer = (streamingService == Spotify) ? [SpotifySessionManager shared] : [AppleMusicSessionManager shared];

}

# pragma mark - Authentication

- (void)authorizeSession {
    
    if (!_musicPlayer || _accessToken) {
        [self postAuthorizedNotification];
        return;
    }
    
    [_musicPlayer authorizeSession];
}

- (void)signOut {
    if (_musicPlayer && _isSessionAuthorized) {
        [_musicPlayer signOut];
        _streamingService = Deezer;
        [self postDeauthorizedNotification];
    }
}

- (void)setAccessToken:(NSString *)accessToken {
    
    _accessToken = accessToken;
    
    if (accessToken) {
        [self postAuthorizedNotification];
        return;
    }
    
    [self postDeauthorizedNotification];
    
}

# pragma mark - Playback

- (void)playTrackWithStreamingId:(NSString *)streamingId {
    if (_musicPlayer) {
        [_musicPlayer playTrackWithStreamingId:streamingId];
    }
}

- (void)pausePlayback {
    if (_musicPlayer && _isPlaying) {
        [_musicPlayer pausePlayback];
    }
}

- (void)resumePlayback {
    
    // if there is no song to resume, play the top song
    NSString *roomTrackId = [[RoomManager shared] currentTrackStreamingId];
    if (roomTrackId == nil) {
        [[RoomManager shared] playTopSong];
        return;
    }
    
    // if the song is paused, resume playback
    if ([roomTrackId isEqualToString:_playerTrackId]) {
        [_musicPlayer resumePlayback];
        return;
    }
    
    [_musicPlayer playTrackWithStreamingId:roomTrackId];
    
}

- (void)validateNewPlayerState {
    
    NSString *roomTrackId = [[RoomManager shared] currentTrackStreamingId];
    
    // check if music player is playing the wrong song
    if (_isPlaying && ![roomTrackId isEqualToString:_playerTrackId]) {
        [[RoomManager shared] stopPlayback];
        [self pausePlayback];
        return;
    }
    
    // if music player is playing the right song, resume
    if (!_isPlaying && roomTrackId != nil) {
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

- (void)didDisconnectRemote {
    [self pausePlayback];
    _playerTrackId = nil;
    self.isPlaying = NO;
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

# pragma mark - Helpers

- (void)postAuthorizedNotification {
    _isSessionAuthorized = YES;
    [[RoomManager shared] reloadCurrentTrackData];
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerAuthorizedNotificaton object:nil];
}

- (void)postDeauthorizedNotification {
    _accessToken = nil;
    _isSessionAuthorized = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerDeauthorizedNotificaton object:nil];
}

@end

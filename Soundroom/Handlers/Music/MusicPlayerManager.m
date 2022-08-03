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

@implementation MusicPlayerManager

+ (instancetype)shared {
    static MusicPlayerManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)setStreamingService:(AccountType)streamingService {
    if (streamingService == Spotify) {
        _streamingService = Spotify;
        _musicPlayer = [SpotifySessionManager shared];
    } else if (streamingService == AppleMusic) {
        _streamingService = AppleMusic;
        _musicPlayer = [AppleMusicSessionManager shared];
    }
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
    if (!roomTrackId) {
        [[RoomManager shared] playTopSong];
        return;
    }
    
    // if the room and player songs match and the player is paused, resume
    if ([roomTrackId isEqualToString:_playerTrackId] && !_isPlaying && _musicPlayer) {
        [_musicPlayer resumePlayback];
        return;
    }
    
    // if there is a song to resume and it is not in the player, start playing it
    if (!_playerTrackId) {
        [_musicPlayer playTrackWithStreamingId:roomTrackId];
        return;
    }
    
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

// TODO: does not resume when u come back
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
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerAuthorizedNotificaton object:nil];
}

- (void)postDeauthorizedNotification {
    _accessToken = nil;
    _isSessionAuthorized = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerDeauthorizedNotificaton object:nil];
}

@end

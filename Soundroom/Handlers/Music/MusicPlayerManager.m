//
//  MusicPlayerManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "MusicPlayerManager.h"
#import "RoomManager.h"
#import "ParseUserManager.h"
#import "SpotifySessionManager.h"
#import "AppleMusicSessionManager.h"

NSString *const MusicPlayerManagerAuthorizedNotificaton = @"MusicPlayerManagerAuthorizedNotificaton";
NSString *const MusicPlayerManagerDeauthorizedNotificaton = @"MusicPlayerManagerDeauthorizedNotificaton";

@implementation MusicPlayerManager {
    NSString *_accessToken;
    BOOL _isSwitchingSong;
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
    
    [self pausePlayback];
    
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
    
    if (![ParseUserManager shouldPlayMusic] || _musicPlayer == nil) {
        return;
    }
    
    [_musicPlayer playTrackWithStreamingId:streamingId];
    _isSwitchingSong = NO;
    
}

- (void)pausePlayback {
    
    if (![ParseUserManager shouldPlayMusic] || _musicPlayer == nil || !_isPlaying) {
        return;
    }
    
    [_musicPlayer pausePlayback];
    
}

- (void)resumePlayback {
    
    if (![ParseUserManager shouldPlayMusic]  || _musicPlayer == NO) {
        return;
    }
    
    // if there is no song to resume, play the top song
    NSString *roomTrackId = [[RoomManager shared] currentTrackStreamingId];
    if (roomTrackId == nil) {
        [[RoomManager shared] playTopSong];
        return;
    }
    
    // if the song is paused, resume playback
    if (!_isPlaying && [roomTrackId isEqualToString:_playerTrackId]) {
        [_musicPlayer resumePlayback];
        return;
    }
    
    [self playTrackWithStreamingId:roomTrackId];
    
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
    
    if (_isSwitchingSong == YES) {
        return;
    }
    
    _isSwitchingSong = YES;
    [self pausePlayback];
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
    
    if (![ParseUserManager shouldPlayMusic] || _musicPlayer == nil) {
        return;
    }
    
    [_musicPlayer sceneWillResignActive];
    
}

- (void)sceneDidBecomeActive {
    
    if (![ParseUserManager shouldPlayMusic] || _musicPlayer == nil) {
        return;
    }
    
    [_musicPlayer sceneDidBecomeActive];
    
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

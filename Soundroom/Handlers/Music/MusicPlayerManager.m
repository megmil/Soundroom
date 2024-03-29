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

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _accountType = Deezer;
    }
    
    return self;
    
}

- (void)setAccountType:(AccountType)accountType {
    
    if (accountType != Spotify && accountType != AppleMusic) {
        return;
    }
    
    _accountType = accountType;
    _musicPlayer = (accountType == Spotify) ? [SpotifySessionManager shared] : [AppleMusicSessionManager shared];
    [self authorizeSession];

}

# pragma mark - Authentication

- (void)authorizeSession {
    
    if (_musicPlayer == nil) {
        return;
    }
    
    if (_accessToken != nil) {
        [self postAuthorizedNotification];
        return;
    }
    
    [_musicPlayer authorizeSession];
    
}

- (void)signOut {
    
    [self pausePlayback];
    
    if (_musicPlayer != nil && [self isSessionAuthorized]) {
        [_musicPlayer signOut];
        [self postDeauthorizedNotification];
    }
    
}

# pragma mark - Playback

- (void)playTrackWithStreamingId:(NSString *)streamingId {
    
    if (![ParseUserManager isCurrentUserPlayingMusic] || _musicPlayer == nil) {
        return;
    }
    
    [_musicPlayer playTrackWithStreamingId:streamingId];
    _isSwitchingSong = NO;
    
}

- (void)pausePlayback {
    
    if (![ParseUserManager isCurrentUserPlayingMusic] || _musicPlayer == nil || !_isPlaying) {
        return;
    }
    
    [_musicPlayer pausePlayback];
    
}

- (void)resumePlayback {
    
    if (![ParseUserManager isCurrentUserPlayingMusic]) {
        return;
    }

    NSString *streamingId = [[RoomManager shared] currentTrackStreamingId];
    
    // if the song is paused, resume playback
    if (!_isPlaying && [streamingId isEqualToString:_playerTrackId]) {
        [_musicPlayer resumePlayback];
        return;
    }
    
    [self playTrackWithStreamingId:streamingId];
    
}

- (void)didEndCurrentSong {
    
    if (_isSwitchingSong) {
        return;
    }
    
    _isSwitchingSong = YES;
    [self pausePlayback];
    [[RoomManager shared] playTopSong];
    
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
    
    if (![ParseUserManager isCurrentUserPlayingMusic] || _musicPlayer == nil) {
        return;
    }
    
    [_musicPlayer sceneWillResignActive];
    
}

- (void)sceneDidBecomeActive {
    
    if (![ParseUserManager isCurrentUserPlayingMusic] || _musicPlayer == nil) {
        return;
    }
    
    [_musicPlayer sceneDidBecomeActive];
    
}

# pragma mark - Properties

- (void)setAccessToken:(NSString *)accessToken {
    
    _accessToken = accessToken;
    
    if ([self isSessionAuthorized]) {
        [self postAuthorizedNotification];
        return;
    }
    
    [self postDeauthorizedNotification];
    
}

- (void)setIsPlaying:(BOOL)isPlaying {
    
    if (_isPlaying == isPlaying) {
        return;
    }
    
    _isPlaying = isPlaying;
    [[RoomManager shared] updatePlayerWithPlayState:_isPlaying];
    
}

- (BOOL)isSessionAuthorized {
    return _accessToken != nil && _accessToken.length != 0;
}

# pragma mark - Helpers

- (void)postAuthorizedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerAuthorizedNotificaton object:nil];
}

- (void)postDeauthorizedNotification {
    _accountType = Deezer;
    _accessToken = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerDeauthorizedNotificaton object:nil];
}

@end

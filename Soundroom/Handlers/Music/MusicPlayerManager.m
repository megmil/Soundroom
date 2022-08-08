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
    
    if (![ParseUserManager shouldCurrentUserPlayMusic] || _musicPlayer == nil) {
        return;
    }
    
    [_musicPlayer playTrackWithStreamingId:streamingId];
    _isSwitchingSong = NO;
    
}

- (void)pausePlayback {
    
    if (![ParseUserManager shouldCurrentUserPlayMusic] || _musicPlayer == nil || !_isPlaying) {
        return;
    }
    
    [_musicPlayer pausePlayback];
    
}

- (void)resumePlayback {
    
    if (![ParseUserManager shouldCurrentUserPlayMusic]) {
        return;
    }
    
    // if there is no song to resume, play the top song
    NSString *roomTrackId = [[RoomManager shared] currentTrackStreamingId];
    if (roomTrackId == nil || roomTrackId.length == 0) {
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
    
    if (![ParseUserManager shouldCurrentUserPlayMusic] || _musicPlayer == nil) {
        return;
    }
    
    [_musicPlayer sceneWillResignActive];
    
}

- (void)sceneDidBecomeActive {
    
    if (![ParseUserManager shouldCurrentUserPlayMusic] || _musicPlayer == nil) {
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
    [[RoomManager shared] reloadCurrentTrackData];
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerAuthorizedNotificaton object:nil];
}

- (void)postDeauthorizedNotification {
    _accountType = Deezer;
    _accessToken = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicPlayerManagerDeauthorizedNotificaton object:nil];
}

@end

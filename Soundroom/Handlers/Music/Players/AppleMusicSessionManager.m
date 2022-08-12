//
//  AppleMusicSessionManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "AppleMusicSessionManager.h"
#import <StoreKit/StoreKit.h>
#import <MediaPlayer/MediaPlayer.h>

static NSString *const credentialsKeyAppleDeveloperToken = @"apple-developer-token";

@implementation AppleMusicSessionManager {
    SKCloudServiceController *_cloudServiceController;
    MPMusicPlayerController *_musicController;
    NSString *_developerToken;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self loadToken];
        [self configureObservers];
        _cloudServiceController = [[SKCloudServiceController alloc] init];
        _musicController = [MPMusicPlayerController systemMusicPlayer];
        [_musicController beginGeneratingPlaybackNotifications];
        
    }
    
    return self;
    
}

- (void)loadToken {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]; // TODO: file scope?
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    _developerToken = credentials[credentialsKeyAppleDeveloperToken];
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePlayerState) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeNowPlayingItem) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
}

# pragma mark - Authorization

- (void)authorizeSession {
    [_cloudServiceController requestUserTokenForDeveloperToken:_developerToken completionHandler:^(NSString *userToken, NSError *error) {
        [[MusicPlayerManager shared] setAccessToken:userToken];
    }];
}

- (void)signOut {
    [_musicController stop];
    [[MusicPlayerManager shared] setAccessToken:nil];
}

# pragma mark - Playback

- (void)playTrackWithStreamingId:(NSString *)streamingId {
    [_musicController setQueueWithStoreIDs:@[streamingId]];
    [_musicController play];
}

- (void)resumePlayback {
    [_musicController play];
}

- (void)pausePlayback {
    [_musicController pause];
}

# pragma mark - PlayerState

- (void)didChangePlayerState {
    BOOL isPlaying = (_musicController.playbackState == MPMusicPlaybackStatePlaying);
    NSString *playbackTrackId = _musicController.nowPlayingItem.playbackStoreID;
    [[MusicPlayerManager shared] setIsPlaying:isPlaying];
    [[MusicPlayerManager shared] setPlayerTrackId:playbackTrackId];
}

- (void)didChangeNowPlayingItem {
    [self didChangePlayerState];
    [[MusicPlayerManager shared] didEndCurrentSong];
}

# pragma mark - Scene Delegate

- (void)openURLContexts:(nonnull NSSet<UIOpenURLContext *> *)URLContexts {
}

- (void)sceneDidBecomeActive {
    // TODO: check new state
}


- (void)sceneWillResignActive {
    // TODO: save state
}


@end

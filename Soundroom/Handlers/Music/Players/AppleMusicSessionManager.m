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

# pragma mark - Authorization

- (void)authorizeSession {
    
    if (!_accessToken) {
        NSString *developerToken = nil;
        [_cloudServiceController requestUserTokenForDeveloperToken:developerToken completionHandler:^(NSString *userToken, NSError *error) {
            self->_accessToken = userToken;
        }];
    }
    
}

- (void)signOut {
    // TODO: disconnect controller
    [_musicController stop];
}

- (BOOL)isSessionAuthorized {
    return _accessToken;
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



# pragma mark - Scene Delegate

- (void)openURLContexts:(nonnull NSSet<UIOpenURLContext *> *)URLContexts {
}

- (void)sceneDidBecomeActive {
}


- (void)sceneWillResignActive {
}

@end

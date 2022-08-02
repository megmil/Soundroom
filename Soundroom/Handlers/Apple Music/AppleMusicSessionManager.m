//
//  AppleMusicSessionManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "AppleMusicSessionManager.h"
#import <StoreKit/StoreKit.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation AppleMusicSessionManager {
    SKCloudServiceController *_cloudServiceController;
    MPMusicPlayerController *_musicController;
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
        _cloudServiceController = [[SKCloudServiceController alloc] init];
        _musicController = [MPMusicPlayerController systemMusicPlayer];
    }
    
    return self;
    
}

- (void)authorizeSession {
    
    if (!_accessToken) {
        
        NSString *developerToken = @"";
        [_cloudServiceController requestUserTokenForDeveloperToken:developerToken completionHandler:^(NSString *userToken, NSError *error) {
            self->_accessToken = userToken;
        }];
        
    }
    
}

- (BOOL)isSessionAuthorized {
    return _accessToken;
}

- (void)playTrackWithId:(NSString *)trackId {
    [_musicController setQueueWithStoreIDs:@[trackId]];
    [_musicController play];
}

- (void)resumePlayback {
    [_musicController play];
}

- (void)pausePlayback {
    [_musicController pause];
}


//- (void)signOut;
//- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
//- (void)sceneWillResignActive;
//- (void)sceneDidBecomeActive;

@end

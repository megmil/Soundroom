//
//  MusicPlayerManager.h
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MusicPlayerManagerAuthorizedNotificaton;
extern NSString *const MusicPlayerManagerDeauthorizedNotificaton;

@protocol MusicPlayer

+ (instancetype)shared;

- (void)authorizeSession;
- (void)signOut;

- (void)playTrackWithStreamingId:(NSString *)streamingId;
- (void)resumePlayback;
- (void)pausePlayback;

- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)sceneWillResignActive;
- (void)sceneDidBecomeActive;

@end

@interface MusicPlayerManager : NSObject

@property (nonatomic, weak) id<MusicPlayer> musicPlayer;
@property (nonatomic) StreamingService streamingService;
@property (nonatomic, strong) NSString *playerTrackId;
@property (nonatomic, strong, nullable) NSString *accessToken;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isSwitchingSong;
@property (nonatomic) BOOL isSessionAuthorized;

+ (instancetype)shared;

- (void)authorizeSession;
- (void)signOut;

- (void)playTrackWithStreamingId:(NSString *)streamingId;
- (void)resumePlayback;
- (void)pausePlayback;
- (void)didEndCurrentSong;
- (void)validateNewPlayerState;

- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)sceneWillResignActive;
- (void)sceneDidBecomeActive;

@end

NS_ASSUME_NONNULL_END

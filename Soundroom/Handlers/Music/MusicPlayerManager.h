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
@property (nonatomic) AccountType accountType;
@property (nonatomic, strong) NSString *playerTrackId;
@property (nonatomic, strong, nullable) NSString *accessToken;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, readonly, getter=isSessionAuthorized) BOOL isSessionAuthorized;

+ (instancetype)shared;

- (void)authorizeSession;
- (void)signOut;
- (void)setAccountType:(AccountType)accountType;

- (void)playTrackWithStreamingId:(NSString *)streamingId;
- (void)resumePlayback;
- (void)pausePlayback;
- (void)didEndCurrentSong;
- (void)didDisconnectRemote;

- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)sceneWillResignActive;
- (void)sceneDidBecomeActive;

@end

NS_ASSUME_NONNULL_END

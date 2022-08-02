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

- (void)authorizeSessionWithCompletion:(void (^)(BOOL succeeded))completion;
- (void)signOutWithCompletion:(void (^)(BOOL succeeded))completion;
- (BOOL)isSessionAuthorized;

- (void)playTrackWithStreamingId:(NSString *)streamingId;
- (void)resumePlayback;
- (void)pausePlayback;
- (NSString *)playbackTrackId;

- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)sceneWillResignActive;
- (void)sceneDidBecomeActive;

@end

@interface MusicPlayerManager : NSObject

@property (nonatomic, weak) id<MusicPlayer> musicPlayer;
@property (nonatomic) BOOL isPlaying;

+ (instancetype)shared;
- (void)authorizeSession;
- (void)signOut;
- (void)resumePlayback;

@end

NS_ASSUME_NONNULL_END

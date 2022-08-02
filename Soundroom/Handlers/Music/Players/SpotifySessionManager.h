//
//  SpotifyRemoteManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import <Foundation/Foundation.h>
#import <SpotifyiOS/SpotifyiOS.h>
#import "MusicPlayerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpotifySessionManager : NSObject <SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate, MusicPlayer>

@property (strong, nonatomic, readonly) NSString *accessToken;
@property (nonatomic) BOOL isSwitchingSong;
@property (nonatomic) BOOL isPlaying;
@property (strong, nonatomic) NSString *appRemoteTrackURI;

@end

NS_ASSUME_NONNULL_END

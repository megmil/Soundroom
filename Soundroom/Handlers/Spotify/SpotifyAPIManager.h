//
//  SpotifyAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "AFNetworking/AFNetworking.h"
#import "Track.h"

#define SpotifyAPIManagerFailedAccessTokenNotification @"SpotifyAPIManagerFailedAccessTokenNotification"

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyAPIManager : AFHTTPSessionManager

+ (instancetype)shared;

- (void)getSongsWithQuery:(NSString *)query completion:(void(^)(NSArray *songs, NSError *error))completion;
- (void)getSongWithSpotifyId:(NSString *)spotifyId completion:(void(^)(Track *song, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END

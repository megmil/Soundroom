//
//  SpotifyAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "AFNetworking/AFNetworking.h"
#import "Track.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const SpotifyAPIManagerFailedAccessTokenNotification;

@interface SpotifyAPIManager : AFHTTPSessionManager

+ (instancetype)shared;

- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion;
- (void)getTrackWithSpotifyId:(NSString *)spotifyId completion:(void(^)(Track *track, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END

//
//  SpotifyAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "AFNetworking/AFNetworking.h"
#import "Song.h"

@interface SpotifyAPIManager : AFHTTPSessionManager

+ (instancetype)shared;

- (void)getSongsWithQuery:(NSString *)query completion:(void(^)(NSArray *songs, NSError *error))completion;
- (void)getSongWithSpotifyId:(NSString *)spotifyId completion:(void(^)(Song *song, NSError *error))completion;

@end

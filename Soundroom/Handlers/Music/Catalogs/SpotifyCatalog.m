//
//  SpotifyCatalog.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "SpotifyCatalog.h"
#import "SpotifySessionManager.h"

@implementation SpotifyCatalog

static NSString *const baseURLString = @"https://api.spotify.com";
static NSString *const searchURLString = @"v1/search?";
static NSString *const getTrackURLString = @"v1/tracks/%@";

static NSString *const tokenParameterName = @"access_token";
static NSString *const typeParameterName = @"type";
static NSString *const queryParameterName = @"q";
static NSString *const trackTypeName = @"track";

- (NSString *)accessToken {
    return [[SpotifySessionManager shared] accessToken];
}

- (NSString *)baseURLString {
    return baseURLString;
}

- (NSString *)getTrackURLString {
    return getTrackURLString;
}

- (NSString *)queryParameterName {
    return queryParameterName;
}

- (NSString *)searchURLString {
    return searchURLString;
}

- (NSString *)tokenParameterName {
    return tokenParameterName;
}

- (NSString *)trackTypeName {
    return trackTypeName;
}

- (NSString *)typeParameterName {
    return typeParameterName;
}

@end

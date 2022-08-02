//
//  AppleMusicCatalog.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "AppleMusicCatalog.h"

@implementation AppleMusicCatalog

NSString *const baseURLString = @"https://api.music.apple.com";
NSString *const searchURLString = @"v1/catalog/us/search?";
NSString *const getTrackURLString = @"v1/catalog/us/songs/%@";

NSString *const tokenParameterName = @"access_token";
NSString *const typeParameterName = @"types";
NSString *const trackTypeName = @"songs";
NSString *const queryParameterName = @"term";

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

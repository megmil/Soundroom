//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/2/22.
//

#import "SpotifyAPIManager.h"

static NSString *const baseURLString = @"https://api.spotify.com";
static NSString *const searchURLString = @"v1/search?";

static NSString *const tokenParameterName = @"access_token";
static NSString *const limitParameterName = @"limit";
static NSString *const typeParameterName = @"type";
static NSString *const queryParameterName = @"q";
static NSString *const trackTypeName = @"track";
static NSString *const upcParameterFormat = @"upc:%@";

static const NSNumber *lookupLimit = @(1);

@implementation SpotifyAPIManager

+ (instancetype)shared {
    static SpotifyAPIManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    self = [self initWithBaseURL:baseURL];
    return self;
}

# pragma mark - Search

- (NSString *)searchURLString {
    return searchURLString;
}

- (NSDictionary *)searchParametersWithToken:(NSString *)token query:(NSString *)query  {
    
    NSDictionary *parameters = @{tokenParameterName:token,
                                 typeParameterName:trackTypeName,
                                 queryParameterName:query};
    return parameters;
    
}

# pragma mark - Lookup

- (NSString *)lookupURLString {
    return searchURLString;
}

- (NSDictionary *)lookupParametersWithToken:(NSString *)token upc:(NSString *)upc {
    
    NSString *query = [NSString stringWithFormat:upcParameterFormat, upc];
    
    NSDictionary *parameters = @{tokenParameterName:token,
                                 limitParameterName:lookupLimit,
                                 queryParameterName:query,
                                 typeParameterName:trackTypeName};
    return parameters;
    
}

@end

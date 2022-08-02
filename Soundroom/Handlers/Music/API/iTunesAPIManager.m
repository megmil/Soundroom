//
//  iTunesAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/2/22.
//

#import "iTunesAPIManager.h"

static NSString *const baseURLString = @"https://itunes.apple.com";
static NSString *const searchURLString = @"search?";
static NSString *const lookupURLString = @"lookup?";

static NSString *const tokenParameterName = @"access_token";
static NSString *const queryParameterName = @"term";
static NSString *const typeParameterName = @"entity";
static NSString *const trackTypeName = @"song";
static NSString *const upcParameterName = @"upc";

@implementation iTunesAPIManager

+ (instancetype)shared {
    static iTunesAPIManager *sharedManager;
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
    return lookupURLString;
}

- (NSDictionary *)lookupParametersWithToken:(NSString *)token upc:(NSString *)upc {
    
    NSDictionary *parameters = @{tokenParameterName:token,
                                 upcParameterName:upc};
    return parameters;
    
}

@end

//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "SpotifyAPIManager.h"
#import "Song.h"
#import "OAuth2Client.h"

static NSString * const baseURLString = @"https://api.spotify.com";

@implementation SpotifyAPIManager

+ (instancetype)shared {
    static SpotifyAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];

    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *clientID = [dict objectForKey: @"spotify_client_id"];
    NSString *secret = [dict objectForKey: @"spotify_client_secret"];
    
    // check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"spotify_client_id"]) {
        clientID = [[NSUserDefaults standardUserDefaults] stringForKey:@"spotify_client_id"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"spotify_client_secret"]) {
        secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"spotify_client_secret"];
    }
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self = [self initWithBaseURL:baseURL];
    
    return self;
}

- (void)getSongsWithQuery:(NSString *)query completion:(void(^)(NSArray *songs, NSError *error))completion {
    // get acccess token
    [[OAuth2Client sharedInstance] accessToken:^(NSString *accessToken) {
        if (accessToken) {
            NSString *authorizationValue = [NSString stringWithFormat:@"Bearer %@", accessToken];
            
            NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
            NSString *urlString = [NSString stringWithFormat:@"v1/search?q=%@&type=track", encodedQuery];
            
            [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [self.requestSerializer setValue:authorizationValue forHTTPHeaderField:@"Authorization"];
            
            [self GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                // progress
            } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable dictionary) {
                NSMutableArray *songs = [Song songsWithDictionary:dictionary];
                completion(songs, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                completion(nil, error);
            }];
        } else {
            // stop
            NSLog(@"API: Error: Access token is nil.");
        }
    }];
}

@end

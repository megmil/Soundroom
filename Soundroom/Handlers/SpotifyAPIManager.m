//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "SpotifyAPIManager.h"
#import "Song.h"
#import <SpotifyiOS/SpotifyiOS.h>

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
    
    self = [super initWithBaseURL:baseURL consumerKey:clientID consumerSecret:secret];
    
    return self;
}

// REQUIRES: filter is "track" "artist" or "album"
- (void)getSongsWithText:(NSString *)text forFilter:(NSString *)filter completion:(void(^)(NSArray *songs, NSError *error))completion {
    
    NSString *queryURLString = [NSString stringWithFormat:@"q=%@:%@", filter, text];
    NSString *urlString = [NSString stringWithFormat:@"v1/search?%@&type=track", queryURLString];
    
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Authorization"];
    
    [self GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        // progress
    } success:^(NSURLSessionDataTask * _Nonnull task, NSArray * _Nullable songDictionaries) {
        NSMutableArray *songs = [Song songsWithArray:songDictionaries];
        completion(songs, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to get songs: %@", error.localizedDescription);
    }];
}

@end

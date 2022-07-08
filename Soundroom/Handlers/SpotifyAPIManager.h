//
//  SpotifyAPIManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "AFNetworking/AFNetworking.h"

@interface SpotifyAPIManager : AFHTTPSessionManager

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *secret;

+ (instancetype)shared;

- (void)getSongsWithQuery:(NSString *)query completion:(void(^)(NSArray *songs, NSError *error))completion;

@end

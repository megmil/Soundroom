//
//  ParseLiveClient.h
//  Soundroom
//
//  Created by Megan Miller on 7/13/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
@import ParseLiveQuery;

NS_ASSUME_NONNULL_BEGIN

@interface ParseLiveClient : NSObject {
    BOOL credentialsLoaded;
    BOOL clientConfigured;
}

@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *clientKey;
@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *subscription;

+ (instancetype)shared;

- (void)connect;

@end

NS_ASSUME_NONNULL_END

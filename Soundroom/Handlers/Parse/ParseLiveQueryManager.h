//
//  ParseLiveClient.h
//  Soundroom
//
//  Created by Megan Miller on 7/13/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "QueueSong.h"
@import ParseLiveQuery;

NS_ASSUME_NONNULL_BEGIN

@interface ParseLiveQueryManager : NSObject {
    BOOL credentialsLoaded;
    BOOL clientConfigured;
}

@property (strong, nonatomic) NSMutableArray<QueueSong*> *queue;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *clientKey;
@property (strong, nonatomic) PFLiveQueryClient *client;

+ (instancetype)shared;

- (void)connect;

@end

NS_ASSUME_NONNULL_END

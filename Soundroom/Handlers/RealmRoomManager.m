//
//  RealmRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "RealmRoomManager.h"
#import "RealmAccountManager.h"
#import "Realm/Realm.h"

@implementation RealmRoomManager

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)createRoom:(SNDRoom *)room {
    RLMRealm *realm = [self defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:room];
    [realm commitWriteTransaction];
}

- (RLMRealm *)realmWithPartition:(NSString *)partition {
    RLMUser *currentUser = [[RealmAccountManager shared] currentUser];
    RLMRealmConfiguration *configuration = [currentUser configurationWithPartitionValue:partition];
    RLMRealm *realm = [RLMRealm realmWithConfiguration:configuration error:nil];
    return realm;
}

- (RLMRealm *)defaultRealm {
    RLMRealm *realm = [RLMRealm defaultRealm];
    return realm;
}

- (RLMApp *)realmApp {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSString *appID = credentials[@"realm-app-id"];
    RLMApp *app = [RLMApp appWithId:appID];
    return app;
}

@end

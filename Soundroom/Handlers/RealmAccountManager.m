//
//  RealmAccountManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "RealmAccountManager.h"

@implementation RealmAccountManager

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion {
    RLMApp *app = [self realmApp]; // TODO: better way to get app?
    RLMEmailPasswordAuth *client = [app emailPasswordAuth];
    [client registerUserWithEmail:username password:password completion:completion];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void(^)(RLMUser * _Nullable user, NSError * _Nullable error))completion {
    RLMApp *app = [self realmApp];
    RLMCredentials *realmCredentials = [RLMCredentials credentialsWithEmail:username password:password];
    [app loginWithCredential:realmCredentials completion:completion];
}

- (void)logoutWithCompletion:(void(^)(NSError *error))completion {
    RLMApp *app = [self realmApp];
    RLMUser *currentUser = [app currentUser];
    [currentUser logOutWithCompletion:completion];
}

- (BOOL)signedIn {
    RLMApp *app = [self realmApp];
    return [app currentUser];
}

- (RLMUser *)currentUser {
    RLMApp *app = [self realmApp];
    return [app currentUser];
}

- (RLMApp *)realmApp {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSString *appID = credentials[@"realm-app-id"];
    RLMApp *app = [RLMApp appWithId:appID];
    return app;
}

@end

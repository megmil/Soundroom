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

- (void)registerUserWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(NSError *error))completion {
    RLMApp *app = [self realmApp];
    RLMEmailPasswordAuth *client = [app emailPasswordAuth];
    [client registerUserWithEmail:email password:password completion:completion];
}

- (void)loginUserWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(RLMUser * _Nullable, NSError * _Nullable))completion {
    RLMApp *app = [self realmApp];
    RLMCredentials *realmCredentials = [RLMCredentials credentialsWithEmail:email password:password];
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

- (RLMApp *)realmApp {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSString *appID = credentials[@"realm-app-id"];
    RLMApp *app = [RLMApp appWithId:appID];
    return app;
}

@end

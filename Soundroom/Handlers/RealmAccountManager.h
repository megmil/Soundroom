//
//  RealmAccountManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "SNDUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface RealmAccountManager : NSObject

+ (instancetype)shared;

- (void)registerWithUsername:(NSString *)username password:(NSString *)password
                  completion:(void(^)(NSError * _Nullable))completion;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
               completion:(void(^)(RLMUser * _Nullable, NSError * _Nullable))completion; // TODO: RLMUser in completion?
- (void)logoutWithCompletion:(void(^)(NSError *error))completion;
- (BOOL)signedIn;
- (RLMUser *)currentUser;

@end

NS_ASSUME_NONNULL_END

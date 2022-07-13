//
//  ParseUserManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseUserManager : NSObject

+ (void)registerWithUsername:(NSString *)username password:(NSString *)password completion:(PFUserResultBlock _Nullable)completion;
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(PFUserResultBlock _Nullable)completion;
+ (void)logoutWithCompletion:(PFUserLogoutResultBlock _Nullable)completion;

+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock _Nullable)completion;
+ (void)getUserWithId:(NSString *)userId completion:(PFObjectResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

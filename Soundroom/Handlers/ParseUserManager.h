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

+ (instancetype)shared; // TODO: remove if possible

- (void)registerWithUsername:(NSString *)username password:(NSString *)password completion:(PFBooleanResultBlock _Nullable)completion; // TODO: completion block
- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(PFBooleanResultBlock _Nullable)completion;
- (void)logoutWithCompletion:(void(^)(NSError * _Nullable error))completion;

- (BOOL)currentUserIsInRoom;
- (NSString *)currentUserRoomId;

@end

NS_ASSUME_NONNULL_END

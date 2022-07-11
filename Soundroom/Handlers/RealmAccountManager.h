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

- (void)registerUserWithEmail:(NSString *)email password:(NSString *)password completion:(void(^)(NSError *error))completion; // TODO: BOOL return vs completion
- (void)logoutWithCompletion:(void(^)(NSError *error))completion;
- (BOOL)signedIn;

@end

NS_ASSUME_NONNULL_END

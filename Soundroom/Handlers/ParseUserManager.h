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

+ (instancetype)shared;

- (void)registerWithUsername:(NSString *)username password:(NSString *)password completion:(PFBooleanResultBlock _Nullable)completion;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

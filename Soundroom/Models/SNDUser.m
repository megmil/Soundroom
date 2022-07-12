//
//  SNDUser.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "SNDUser.h"

@implementation SNDUser

@dynamic _id;

- (instancetype)initWithUsername:(NSString *)username {
    
    self = [super init];
    
    if (self) {
        self.username = username;
    }
    
    return self;
}

+ (NSString *)primaryKey {
    return @"_id";
}

+ (NSArray<NSString *> *)requiredProperties {
    return @[@"_id", @"username"];
}

@end

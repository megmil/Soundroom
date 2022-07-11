//
//  SNDUser.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "SNDUser.h"

@implementation SNDUser

- (instancetype)initWithUsername:(NSString *)username userID:(NSString *)userID {
    
    self = [super init];
    
    if (self) {
        self.username = username;
        self.userID = userID;
        self.partition = [NSString stringWithFormat:@"user=%@", userID];
    }
    
    return self;
}

@end

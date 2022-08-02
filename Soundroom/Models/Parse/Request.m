//
//  Request.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Request.h"
#import "ParseConstants.h"

@implementation Request

@dynamic objectId;
@dynamic roomId;
@dynamic userId;
@dynamic upc;

+ (nonnull NSString *)parseClassName {
    return RequestClass;
}

- (instancetype)initWithUPC:(NSString *)upc roomId:(NSString *)roomId userId:(NSString *)userId {
    
    self = [super init];
    
    if (self) {
        self.roomId = roomId;
        self.userId = userId;
        self.upc = upc;
    }
    
    return self;
    
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Request class]]) {
        Request *request = (Request *)object;
        return [self.objectId isEqualToString:request.objectId];
    }
    return NO;
}

@end

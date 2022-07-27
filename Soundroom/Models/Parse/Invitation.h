//
//  Invitations.h
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Invitation : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic) BOOL isPending;

- (instancetype)initWithUserId:(NSString *)userId roomId:(NSString *)roomId isPending:(BOOL)isPending;

@end

NS_ASSUME_NONNULL_END

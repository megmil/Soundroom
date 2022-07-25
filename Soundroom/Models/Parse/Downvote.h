//
//  Downvote.h
//  Soundroom
//
//  Created by Megan Miller on 7/23/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Downvote : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *requestId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userId;

@end

NS_ASSUME_NONNULL_END

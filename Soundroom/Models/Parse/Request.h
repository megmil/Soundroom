//
//  Request.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Request : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *isrc;

- (instancetype)initWithISRC:(NSString *)isrc roomId:(NSString *)roomId userId:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END

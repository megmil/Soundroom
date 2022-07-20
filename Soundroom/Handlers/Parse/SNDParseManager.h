//
//  QueryManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNDParseManager : NSObject

@property (nonatomic, strong) PFQuery *queryForAcceptedInvitations;
@property (nonatomic, strong) PFQuery *queryForAllRoomMembers;

+ (instancetype)shared;

+ (void)deleteAllObjects:(NSArray *)objects;

@end

NS_ASSUME_NONNULL_END

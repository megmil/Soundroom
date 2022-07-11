//
//  SNDUser.h
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNDUser : RLMObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *partition;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *currentRoomID;
@property (nonatomic, strong) NSString *avatarImageURLString; // TODO: separate RLMObject?

@end

NS_ASSUME_NONNULL_END

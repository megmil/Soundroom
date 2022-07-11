//
//  SNDUser.h
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface SNDUser : RLMObject

@property (nonatomic, strong) NSString *username;
// recent rooms - only needed for current user
// profile picture

@end

NS_ASSUME_NONNULL_END

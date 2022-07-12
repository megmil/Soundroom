//
//  ParseRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Room.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseRoomManager : NSObject

+ (instancetype)shared;

- (void)createRoomWithTitle:(NSString *)title completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

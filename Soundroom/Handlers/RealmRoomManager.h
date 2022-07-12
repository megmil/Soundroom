//
//  RealmRoomManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import <Foundation/Foundation.h>
#import "SNDRoom.h"

NS_ASSUME_NONNULL_BEGIN

@interface RealmRoomManager : NSObject

+ (instancetype)shared;

- (void)createRoom:(SNDRoom *)room;

@end

NS_ASSUME_NONNULL_END

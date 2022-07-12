//
//  Room.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SNDRoom.h"
#import "RealmRoomManager.h"
#import "Realm/Realm.h"

@implementation SNDRoom

@dynamic _id;

+ (void)createRoomWithTitle:(NSString *)title {
    SNDRoom *room = [SNDRoom new];
    room.title = title;
    
    [[RealmRoomManager shared] createRoom:room];
}

- (RLMObjectId *)roomID {
    return self._id;
}

@end

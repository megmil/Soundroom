//
//  Room.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SNDRoom.h"
#import "RealmAccountManager.h"
#import "Realm/Realm.h"

@implementation SNDRoom

- (instancetype)initWithTitle:(NSString *)title {
    
    self = [super init];
    
    if (self) {
        self.title = title;
        
        //self.roomID = roomID;
        //self.partition = [NSString stringWithFormat:@"room=%@", roomID];
    }
    
    return self;
}

@end

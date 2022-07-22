//
//  QueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import "SNDParseManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"

@implementation SNDParseManager

+ (void)deleteAllObjects:(NSArray *)objects {
    for (PFObject *object in objects) {
        [object deleteInBackground];
    }
}

@end

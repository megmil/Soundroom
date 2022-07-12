//
//  Room.h
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Room : PFObject<PFSubclassing>

@property (nonatomic, strong) User *host;
@property (nonatomic, strong) NSMutableArray <User *> *members;
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) NSMutableArray *playedSongs;

@property (nonatomic, strong) NSString *title;
// room image

@end

NS_ASSUME_NONNULL_END
